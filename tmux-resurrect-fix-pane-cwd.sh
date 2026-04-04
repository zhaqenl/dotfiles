#!/usr/bin/env bash
# tmux-resurrect post-save-layout hook
#
# Fixes two issues in the resurrect save file:
#
# 1. Wrong pane directories: #{pane_current_path} follows the foreground
#    process's cwd, not the shell's. This reads the shell's actual cwd
#    from /proc/<pane_pid>/cwd.
#
# 2. Empty pane_title field corruption: bash's IFS read collapses
#    consecutive tabs (empty fields) because tab is IFS whitespace.
#    When pane_title is empty, dump_panes shifts all subsequent fields.
#    This detects and repairs the shift.
#
# To revert: remove the @resurrect-hook-post-save-layout line from .tmux.conf

RESURRECT_FILE="$1"

if [ -z "$RESURRECT_FILE" ] || [ ! -f "$RESURRECT_FILE" ]; then
	exit 0
fi

d=$'\t'

# Build maps from tmux: pane_id -> shell cwd, pane_id -> pane title
cwd_file=$(mktemp)
title_file=$(mktemp)
trap 'rm -f "$cwd_file" "$title_file"' EXIT

while IFS=$d read -r pane_id pane_pid; do
	if [ -n "$pane_pid" ] && [ -d "/proc/$pane_pid" ]; then
		real_cwd="$(readlink "/proc/$pane_pid/cwd" 2>/dev/null)"
		if [ -n "$real_cwd" ]; then
			printf '%s\t%s\n' "$pane_id" "$real_cwd" >> "$cwd_file"
		fi
	fi
done < <(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}${d}#{pane_pid}")

tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}${d}#{pane_title}" > "$title_file"

# Use awk to patch the save file.
# awk with FS="\t" correctly handles consecutive tabs as separate fields,
# unlike bash read which collapses them.
awk -F'\t' -v OFS='\t' -v cwd_f="$cwd_file" -v title_f="$title_file" '
BEGIN {
	while ((getline line < cwd_f) > 0) {
		split(line, parts, "\t")
		cwds[parts[1]] = parts[2]
	}
	close(cwd_f)

	while ((getline line < title_f) > 0) {
		split(line, parts, "\t")
		titles[parts[1]] = parts[2]
	}
	close(title_f)
}
/^pane\t/ {
	pane_id = $2 ":" $3 "." $6

	# Detect empty-title field corruption:
	# Correct format: $7=title  $8=:dir  $9=0|1  $10=cmd  $11=:fullcmd
	# Corrupted:      $7=:dir   $8=0|1   $9=cmd  $10=pid  $11=:
	# Detection: field 8 should start with ":" (it is :dir)
	if ($8 !~ /^:/) {
		# Corrupted — unshift fields and restore title
		real_title = (pane_id in titles) ? titles[pane_id] : ""
		saved_dir = $7       # was placed in title slot
		saved_active = $8    # was placed in dir slot
		saved_cmd = $9       # was placed in active slot
		# $10 is leaked pane_pid, $11 is ":" (broken full_command)

		$7 = real_title
		$8 = saved_dir
		$9 = saved_active
		$10 = saved_cmd
		$11 = ":"            # full_command lost, use empty
	}

	# Prevent empty title from causing field collapse during restore
	# (restore.sh also uses bash IFS read which collapses consecutive tabs)
	if ($7 == "") $7 = " "

	# Replace dir with shell cwd from /proc
	if (pane_id in cwds) {
		new_dir = cwds[pane_id]
		gsub(/ /, "\\ ", new_dir)
		$8 = ":" new_dir
	}

	print
	next
}
{ print }
' "$RESURRECT_FILE" > "${RESURRECT_FILE}.fixcwd"

mv "${RESURRECT_FILE}.fixcwd" "$RESURRECT_FILE"
