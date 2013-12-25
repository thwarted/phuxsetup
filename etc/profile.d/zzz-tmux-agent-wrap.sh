
function tmx() {
    local SSHADD=/usr/bin/ssh-add
    local LN=/bin/ln

    case $TERM in
        screen* )
            echo "Let's not try to run tmux inside tmux" >&2
            return 1
            ;;
        * )
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
                    fi
                fi
            fi
            ;;
    esac
}

function _spawn_tmux() {
    local TMUX=/usr/bin/tmux
    local targetses=${1:-all}

    if [ "$targetses" = "ls" ]; then
        # list the sessions
        $TMUX ls
    else
        mytty=$(tty | cut -f3- -d/)
        sessioninstance="$targetses $mytty"
        if $TMUX has-session -t "$targetses"; then
            # found the requested session, attach to it
            $TMUX -2 new-session -s "$sessioninstance" -t "$targetses" 
        else
            # create a new detached session, set an option on it, and attach to it
            $TMUX -2 \
                new-session -d -s "$targetses" \; \
                set -t "$targetses" destroy-unattached off \; \
                new-session -s "$sessioninstance" -t "$targetses"
        fi
    fi
}
