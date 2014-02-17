#!/bin/bash

# source this file in the shell
#
# the shell function tmx will start a new, persistent (meaning you can be
# connected to it multiple times at the same time), with the ssh-agent
# connection available even if you get disconnected and reconnect
#
# It starts up multiple tmux servers, one for each name, rather than one
# server with multiple sessions in it.  This avoids the accidental killing
# of all sessions while in one of them.  tmux "sessions" are kind of
# convoluted (when using multiple attachments).

function tmx() {
    local SSHADD=/usr/bin/ssh-add
    local LN=/bin/ln

    case $TERM in
        screen* )
            echo "Let's not try to run tmux inside tmux" >&2
            return 1
            ;;
    esac

    # if the auth socket variable is empty, don't do anything
    if [[ "$SSH_AUTH_SOCK" ]]; then
        # include USER to protect against shared HOME directories (rare)
        NEWSOCK=$HOME/.agent-sshtmux-$USER.sock
        if [[ "$SSH_AUTH_SOCK" != "$NEWSOCK" ]]; then
            # test if the auth sock we have is actually working
            # don't link to a dead socket
            if $SSHADD -l > /dev/null 2>&1; then
                $LN -sf $SSH_AUTH_SOCK $NEWSOCK
                SSH_AUTH_SOCK=$NEWSOCK _spawn_tmux "$@"
            else
                echo "tmx: agent appears to have no keys (agent locked?)" >&2
            fi
        else
            echo "tmx: SSH_AUTH_SOCK already redirected, odd state" >&2
        fi
    else
        echo "tmx: SSH_AUTH_SOCK is not set" >&2
    fi
}

function _spawn_tmux() {
    local TMUX=/usr/bin/tmux

    local thename=${1:-default}
    local SOCKDIR=/tmp/tmux-$EUID

    if [ "$thename" = "ls" ]; then
        if [[ -d $SOCKDIR ]]; then
            /bin/find $SOCKDIR -type s -exec /sbin/fuser {} \; 2>&1 |
                /bin/awk -F '[[:space:]:]' '{ print $1 }' |
                /usr/bin/xargs --no-run-if-empty -n 1 /bin/basename
        else
            echo "$SOCKDIR not found." >&2
        fi
        return 0
    fi

    if ! $TMUX -L $thename has-session -t "default" 2>/dev/null ; then
        # server not running, start it
        # create a new detached session, set an option on it
        $TMUX -L $thename -2 \
            new-session -d -s "default" \; \
            set -t "default" destroy-unattached off \;
    fi
    mytty=$( /usr/bin/tty )
    sessioninstance="${mytty#/*/} $thename"
    $TMUX -L $thename -2 new-session -s "$sessioninstance" -t "default" 
}

