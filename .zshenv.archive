# -*- mode: sh; coding: utf-8 -*-

## Variables
PS1="%F{cyan}%B%n%b%f%B%F{magenta} %f%b%B%F{red}%m${CHROOT_PROMPT}%f%b %F{green}%B%0d%b%f${vcs_info_msg_0_} %D{%n}%F{green}★%f%F{white} "
BINDIR=$HOME/bin

export LOCALE_ARCHIVE=$(readlink ~/.nix-profile/lib/locale)/locale-archive
export PG_LOG_PATH="/etc/postgresql/9.5/main/postgresql.conf"

## Go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

## Pyenv
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.pyenv/bin:$HOME/anaconda3/bin:$PATH
eval "$(pyenv init -)"

## GIT_EDITOR
export GIT_EDITOR="emacsclient -nw"

## SSH
alias ssh="ssh -o ServerAliveInterval=15"

typeset -aU path

## Functions
# Utilities --------------------------------------------------------------------
function tmux () {
    local res_dir=$HOME/.tmux/resurrect

    if [[ $# == 0 ]]; then
        =tmux
    elif [[ "$1" = <-> ]]; then
        =tmux attach -t $@
    else
        case $1 in
            (kill|ks) shift; =tmux kill-session -t $@ ;;
            (list|ls) shift; =tmux list-sessions $@ ;;
            (listr|lr) shift; ls $@ $res_dir ;;
            (lr!) tmux lr -l -tr -A -F --color ;;
            (clean) shift; (cd $res_dir; find . -type f ! -name $(basename $(readlink -f last)) -print0 | xargs -0 rm -vf) ;;
            (*) =tmux $@
        esac
    fi
}

function s () {
    command sudo $@
}

function ssh-personal () {
    eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa_personal
}

function lss () {
    ls -FAtr --color $@
}

function l () {
    lss -lh $@
}

function o () {
    xdg-open $@
}

function xc () {
    local sel=clipboard
    if [[ $# == 1 ]]
    then
        if [[ -f "$1" ]]
        then
            echo -n "$(fp $1)" | xclip -selection $sel
        else
            echo -n "$@" | xclip -selection $sel
        fi
    else
        xclip -selection $sel "$@"
    fi
}

function nman () {
    local item=$1
    local section=${2:-1}

    man $(nix out-path $item)/share/man/man${section}/${item}.${section}.gz
}

function man () {
    env LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
        =man $@ 2> /dev/null || \
        nman $@
}

function psg () {
    pgrep --list-full --list-name --full $@
}

# function a0() {
#     xmodmap ~/.Xmodmap
# }

function mhost(){
    make && python2.7 -m SimpleHTTPServer
}

autoload zcalc
# ------------------------------------------------------------------------------

# Text Editor ------------------------------------------------------------------
# `ed` is now a systemd service
# function ed () {
#     if [[ -n "$(psg 'emacs --daemon')" || -n "$(psg 'emacs --smid')" ]]; then
#         return 1
#     else
#         [[ -f "$HOME/.emacs.d/desktop.lock" ]] \
    #             && rm -f "$HOME/.emacs.d/desktop.lock"
#         emacs --daemon
#     fi
# }

function e () {
    emacsclient -nw $@
}

function se () {
    sudo emacs -nw $@
}
# ------------------------------------------------------------------------------

# Git --------------------------------------------------------------------------
# Open current git directory’s remote link in browser
function gl () {
    brave `echo "$(git remote -v | grep fetch | head -1 | cut -f2 | cut -d' ' -f1 | sed 's/....$//g' | sed 's/$/\/tree\//')$(git branch | grep \* | cut -c 3-)"`
}

function gls () {
    brave `echo "$(git remote -v | grep fetch | head -1 | cut -f2 | cut -d' ' -f1 | sed 's/git@//g' | sed 's/:/\//g' | sed 's/....$//g' | sed 's/$/\/tree\//')$(git branch | grep \* | cut -c 3-)"`
}

function gs () {
    git status
}

# Display last commit’s message
function gd () {
    git log | head -n 5 | tail -n 1 | xargs
}

function gb () {
    if [[ $1 ]]; then
        git fetch origin \
            && git checkout -b $1 origin/$1
    fi
}

function gpo () {
    if [[ $1 ]]; then
        git push origin $1
    fi
}

function gtfo () {
    if [[ $1 ]]; then
       git fetch origin $1
    fi
}

function grba () {
    git rebase --autostash
}

# Run inside git branch to merge to
function gm () {
    if [[ $1 && $2 ]]; then
        git checkout $1 \
            && git merge -s ours $2 \
            && git checkout $2 \
            && git merge $1
    fi
}

function ncust () {
    if [[ $1 ]]; then
        ngrok http --domain=bull-prepared-informally.ngrok-free.app $1
    fi
}
# ------------------------------------------------------------------------------

# Multimedia -------------------------------------------------------------------
function laud () {
    echo "Active applications using ALSA:"

    # https://askubuntu.com/questions/748498/why-does-lsof-complain-about-tracefs
    if [[ $(mount | grep debugfs) ]]; then
        sudo umount $(mount | grep debugfs | awk '{print $3}')
    fi

    lsof /dev/snd/* | tail -n +2
    echo ""
    echo "hw_params:"
    cat /proc/asound/AUDIO/pcm0p/sub0/hw_params
    echo ""
    cat /proc/asound/AUDIO/stream0 \
        | grep -e Playback -e Status -e freq -e Format
}

# Test capture and playback devices
function af () {
    arecord -f dat | aplay -
}

function am () {
    alsamixer -V all -D hw:AUDIO
}

function sar () {
    sudo /etc/init.d/alsa-utils stop && \
        sleep 1 && \
        sudo alsa force-reload && \
        sleep 1 && \
        sudo /etc/init.d/alsa-utils start
}

function pak () {
    pulseaudio --kill && sleep 2 && pulseaudio --kill
}

function pas () {
    pulseaudio --start
}

function mpr () {
    if [[ $1 ]]; then
        mplayerstart --resume $1
    fi
}

function smp () {
    if [[ $1 ]]; then
        smplayer $1
    fi
}

function rew () {
    roomeqwizard
}
# ------------------------------------------------------------------------------

# Manual startups (special flags and options) ----------------------------------
function brave () {
    brave-browser-stable --audio-buffer-size=2048 $@
}

function spot () {
    spotify --show-console $@
}

function ff () {
    firefox $@
}
# ------------------------------------------------------------------------------

# Convenience utilities --------------------------------------------------------
function getip() {
    if [[ $1 ]]; then
        nslookup $1 \
            | grep 'Address:' \
            | grep -v '127.0.0.1#53' \
            | grep -v '1.1.1.1#53' \
            | awk '{print $2}' \
            | tee >(xclip -selection clipboard)
    fi
}

function srem () {
    if [[ $1 ]]; then
        sudo apt remove $1 \
            && sudo apt purge $1 \
            && sudo apt autoremove
    fi
}

function crem () {
    sudo rm /var/crash/*
}

function tarz () {
    if [[ $1 ]]; then
        tar Ovc $1 \
            | pxz -9 -c - > $1.tar.xz
    fi
}

# Remove extracted files from archive
function 7zrem () {
    7z l $1 | awk ' {print $6} ' | awk '
      function basename(file) {
        sub(".*/", "", file)
        return file
      }
      {print basename($1)} ' | xargs rm -rf
}
# ------------------------------------------------------------------------------

# Tinkering with `emem` --------------------------------------------------------
function skel_reset () {
    git fetch --all && git reset --hard origin/experimental && git clean -fd
}

function make_emem () {
    make -B BUILDER="java -jar $HOME/bin/emem.jar"
}
# ------------------------------------------------------------------------------

# Odoo functions ---------------------------------------------------------------
# Ripgrep for Odoo
function mrg() {
    rg -F -S -g '!*.po' \
       -g '!*.pot' \
       -g '!*.js' \
       -g '!*.css' \
       -g '!*.svg' \
       -g '!*.*~' \
       -g '!*.*#' $@
}

function o7 () {
    /usr/bin/python2.7 \
        /opt/odoo7/openerp-server \
        -c /etc/odoo7.conf \
        $@
}

function o8 () {
    /opt/odoo8_2/odoo.py \
        -c /etc/odoo8_2.conf \
        --auto-reload $@
}

function o11com () {
    /usr/bin/python3.5 \
    /opt/odoo11com/odoo11com-server/odoo-bin \
        -c /etc/odoo11com-server.conf \
        --dev=all $@
}

function o11ent () {
    /opt/odooEnt/odooEnt-server/odoo-bin \
        -c /etc/odooEnt-server.conf \
        --dev=all $@
}

function o12com () {
    /usr/bin/python3.6 \
    /opt/odoo12/odoo12-server/odoo-bin \
        -c /etc/odoo12-server.conf \
        --dev=all $@
}

function o12ent () {
    /usr/bin/python3.6 \
        /opt/odoo12Ent/odoo12Ent-server/odoo-bin \
        -c /etc/odoo12Ent-server.conf \
        --dev=all $@
}

function o13ent () {
    /usr/bin/python3.6 \
        /opt/odoo13/odoo/odoo-bin \
        -c /etc/odoo13.conf \
        --dev=all $@
}

function o14ent () {
    /usr/bin/python3.6 \
        /opt/odoo14ent/odoo/odoo-bin \
        -c /etc/odoo14ent.conf \
        --dev=all $@
}

function o15ent () {
    /home/devdesk4/anaconda3/bin/python3.7 \
        /opt/odoo15ent/odoo-bin \
        -c /etc/odoo15ent.conf \
        --dev=all $@
}
# ------------------------------------------------------------------------------

# Workarounds ------------------------------------------------------------------
# Add `precmd` hook function (executed before each prompt).
precmd() {
    # Re-set `automatic-rename` value (without this, the window status of
    # restored tmux windows will not automatically rename).
    tmux set automatic-rename on
}
# ------------------------------------------------------------------------------
