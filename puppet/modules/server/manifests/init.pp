
class server {

    include users
    include authentication::pamdsudo
    include authentication::sudoers
    include authentication::sshd

    file { "/etc/profile.d/zzz-shell-custom.sh":
        owner => root,
        group => root,
        mode => 0644,
        source => "puppet:///modules/server/etc/profile.d/zzz-shell-custom.sh"
    }

    file { "/etc/profile.d/zzz-tmux-agent-wrap.sh":
        owner => root,
        group => root,
        mode => 0644,
        source => "puppet:///modules/server/etc/profile.d/zzz-tmux-agent-wrap.sh"
    }

    file { "/etc/profile.d/git-prompt.sh":
        owner => root,
        group => root,
        mode => 0644,
        source => "puppet:///modules/server/etc/profile.d/git-prompt.sh"
    }

}

