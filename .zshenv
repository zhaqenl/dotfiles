# -*- mode: sh; coding: utf-8 -*-

## Variables

PATH=$PATH:$HOME/bin
PS1="%F{cyan}%B%n%b%f%B%F{magenta} %f%b%B%F{red}%m${CHROOT_PROMPT}%f%b %F{green}%B%0d%b%f${vcs_info_msg_0_} %D{%n}%F{green}★%f%F{white} "
BINDIR=$HOME/bin

export LOCALE_ARCHIVE=$(readlink ~/.nix-profile/lib/locale)/locale-archive
export PG_LOG_PATH="/etc/postgresql/9.5/main/postgresql.conf"

## Pyenv
export PATH=$HOME/bin:$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"

## Functions

function page () {
  which $1 | less
}

function a () {
  local op=

  if (( ! $#1 )); then
    page $0
  else
    op=$1
    shift

    case $op in
      (get) s apt-get $@ ;;
      (cache) apt-cache $@ ;;
      (file) s apt-file $@ ;;
      (att) s aptitude $@ ;;
      (s)  $0 cache search $@ ;;
      (fs) $0 file search $@ ;;
      (h)  $0 cache show $@ ;;
      (v)  $0 cache policy $@ ;;
      (i)  $0 get install $@ ;;
      (ri) $0 get install --reinstall $@ ;;
      (r)  $0 get remove $@ ;;
      (p)  $0 get purge $@ ;;
      (d)  $0 cache depends $@ ;;
      (rd) $0 cache rdepends $@ ;;
      (o)  $0 get source $@ ;;
      (u)  $0 get update $@ ;;
      (uf) $0 file update $@ ;;
      (fu) $0 get dist-upgrade $@ ;;
      (su) $0 get upgrade $@ ;;
      (c)  $0 get clean $@ ;;
      (ac) $0 get autoclean ;;
      (f)  $0 get -f install $@ ;;
      (y)  $0 get -q -y -d dist-upgrade $@ ;;
      (ar) $0 get autoremove ;;
      (rm) s rm /var/lib/dpkg/lock /var/lib/apt/lists/lock ;;

      (*)  return 1 ;;
    esac
  fi
}

function b () {
  if [[ -d "$1" ]]; then
      x ahoviewer $1
  else
      imv $1
  fi
}

function s () {
  command sudo $@
}

function l () {
  ls -FAtr --color $@
}

function ll () {
  l -l $@
}

function la () {
  ls -FA --color $@
}

function lk () {
  la -l $@
}

function y () {
  youtube-dl $@
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

## Nix

#. $HOME/.nix-profile/etc/profile.d/nix.sh

# export TERM=xterm-256color

bindkey \e= copy-prev-shell-word

function psg () {
    pgrep --list-full --list-name --full $@
}

function psk () {
    for name ($@)
        {
            for pid ($(psg $name | awk '{print $1}'))
                {
                    kill $pid
                }
        }
}

function ed () {
    if [[ -n "$(psg 'emacs --daemon')" || -n "$(psg 'emacs --smid')" ]]; then
        return 1
    else
        [[ -f "$HOME/.emacs.d/desktop.lock" ]] && rm -f "$HOME/.emacs.d/desktop.lock"
        emacs --daemon
    fi
}

function e () {
    emacsclient -nw $@
}

function make_emem () {
    make -B BUILDER="java -jar $HOME/bin/emem.jar"
}

function plr () {
    pulseaudio -k && pulseaudio --start
}

function mute () { "$@" >& /dev/null }
function mutex () { "$@" >& /dev/null &| }
function x () { mutex $@ }
function z ()  { exec zsh }

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

function fp () { echo "${1:A}" }

function c () {
    local sel=clipboard

    if [[ $# == 1 ]]; then
        if [[ -f "$1" ]]; then
            echo -n "$(fp $1)" | xclip -selection $sel
        else
            echo -n "$@" | xclip -selection $sel
        fi
    else
        xclip -selection $sel "$@"
    fi
}

function c! () { echo $@ | c }
function c@ () { c < $@ }

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

function c-int () {
  ifstat-legacy -S
}

function xs () {
  xscreensaver -no-splash&
}

function skel_reset () {
  git fetch --all && git reset --hard origin/experimental && git clean -fd
}

function odeb () {
    sudo tail -n50 /var/log/odoo8/odoo8-server.log
}

function ores () {
    sudo service odoo8-server restart
}

function venv () {
  source `which virtualenvwrapper.sh`
}

autoload zcalc
