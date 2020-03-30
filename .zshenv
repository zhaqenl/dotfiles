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

## GIT_EDITOR
export GIT_EDITOR="emacsclient -nw"

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

function a0() {
    xmodmap ~/.Xmodmap
}

autoload zcalc
# ------------------------------------------------------------------------------

# Text Editor ------------------------------------------------------------------
function ed () {
    if [[ -n "$(psg 'emacs --daemon')" || -n "$(psg 'emacs --smid')" ]]; then
        return 1
    else
        [[ -f "$HOME/.emacs.d/desktop.lock" ]] \
            && rm -f "$HOME/.emacs.d/desktop.lock"
        emacs --daemon
    fi
}

function e () {
    emacsclient -nw $@
}

function se () {
    s emacs -nw $@
}
# ------------------------------------------------------------------------------

# Multimedia -------------------------------------------------------------------
function laud () {
    lsof /dev/snd/*
}

function sar () {
    sudo alsa reload
}

function pak () {
    pulseaudio --kill && sleep 0.5 && pulseaudio --kill
}

function pas () {
    pulseaudio --start
}

function mpr () {
    if [[ $1 ]]; then
        mplayerstart --resume $1
    fi
}
# ------------------------------------------------------------------------------

# Manual startups (special flags and options) ----------------------------------
function brave () {
    brave-browser-stable --audio-buffer-size=2048
}

function spot () {
    spotify --show-console
}
# ------------------------------------------------------------------------------

# Steroids ---------------------------------------------------------------------
function srem () {
    if [[ $1 ]]; then
        sudo apt remove $1 \
            && sudo apt purge $1 \
            && sudo apt autoremove
    fi
}

function tarz() {
    if [[ $1 ]]; then
        tar Ovc $1 \
            | pxz -9 -c - > $1.tar.xz
    fi
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
    rg -i -g '!*.po' -g '!*.pot' -g '!*.js' -g '!*.css' -g '!*.*~' -g '!*.*#' $@
}

function ostart8 () {
    if [[ $1 ]]; then
        sudo systemctl stop odoo8 \
            && /opt/odoo8/odoo8-server/odoo.py \
                   -c /etc/odoo8-server.conf \
                   --db-filter $1 \
                   --auto-reload
    else
        echo "Choose a database!"
    fi
}

function ostart11com () {
    if [[ $1 ]]; then
        sudo systemctl stop odoo11com \
            && /opt/odoo11com/odoo11com-server/odoo-bin \
                   -c /etc/odoo11com-server.conf \
                   --db-filter $1 \
                   --dev=all
    else
        echo "Choose a database!"
    fi
}

function ostart11ent () {
    if [[ $1 ]]; then
        sudo systemctl stop odooEnt \
            && /opt/odooEnt/odooEnt-server/odoo-bin \
                   -c /etc/odooEnt-server.conf \
                   --db-filter $1 \
                   --dev=all
    else
        echo "Choose a database!"
    fi
}

function ostart12com () {
    if [[ $1 ]]; then
        sudo systemctl stop odoo12 \
            && /opt/odoo12/odoo12-server/odoo-bin \
                   -c /etc/odoo12-server.conf \
                   --db-filter $1 \
                   --dev=all
    else
        echo "Choose a database!"
    fi
}

function ostart12ent () {
    if [[ $1 ]]; then
        sudo systemctl stop odoo12Ent \
            && /opt/odoo12Ent/odoo12Ent-server/odoo-bin \
                   -c /etc/odoo12Ent-server.conf \
                   --db-filter $1 \
                   --dev=all
    else
        echo "Choose a database!"
    fi
}
# ------------------------------------------------------------------------------
