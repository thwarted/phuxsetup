HISTSIZE=10000
if type -t __git_ps1 >/dev/null; then
    PS1='\[\e[1;34m\]\u\[\e[0;39m\]@\[\e[0;32m\]\h\[\e[0;39m\]:\[\e[1;33m\]\w\[\e[0;39m\]$(test -z "$GIT_PS1_DISABLE" && __git_ps1 " \[\e[1;36m\](%s)\[\e[0;39m\] ")\$ '
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
else
    PS1='\[\e[1;34m\]\u\[\e[0;39m\]@\[\e[1;32m\]\h\[\e[0;39m\]:\[\e[1;33m\]\w\[\e[0;39m\]\$ '
fi

case $TERM in
    screen* )
        PS1='\[\033k'$( hostname -s )'\033\\\]'"$PS1"
        ;;
esac

alias ll='ls -l'
alias df='df -x tmpfs -x rootfs -x devtmpfs'
alias ppj='python -mjson.tool'
alias psx='ps axwf'

export LESS=-XR

export VISUAL=vim
export EDITOR=vim

if [[ -x ~/bin ]]; then
    pathmunge ~/bin
fi

pathmunge /usr/local/bin after

export PS_FORMAT='user:10,pid,%cpu,%mem,vsz:8,rss:8,tty,stat,start,time:11,cmd'
