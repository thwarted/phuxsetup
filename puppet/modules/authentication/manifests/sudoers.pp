
class authentication::sudoers {
    # we'll drop files in /etc/sudoers.d here, which are read at the bottom of /etc/sudoers
    # so any settings here will override what's in sudoers.

    if $is_vagrant {
        file { "/etc/sudoers.d/vagrant":
            owner => root,
            group => root,
            mode => 0440,
            content => "# this file is managed by puppet\nvagrant ALL=(ALL) NOPASSWD: ALL\n"
        }
    } else {
        file { "/etc/sudoers.d/vagrant":
            ensure => absent
        }
    }

    file { "/etc/sudoers.d/000defaults":
        owner => root,
        group => root,
        mode => 0440,
        content => "# this file is managed by puppet\nDefaults    !requiretty\nDefaults    env_keep += \"SSH_AUTH_SOCK\"\n"
    }

    # the file that specifies the more general settings needs to appear earlier in the
    # the file ordering, since the last entry that matches the user and the request is used
    # then more specific stuff needs to come after this one.
    # that is, "ALL=(ALL) ALL" is more general than just about anything else
    # from sudoers(5):
    #
    #   SUDOERS FILE FORMAT
    #
    #   When multiple entries match for a user, they are applied in order.  Where there
    #   are multiple matches, the last match is used (which is not necessarily the most
    #   specific match).

    $puphead = "# this file is managed by puppet"

    file { "/etc/sudoers.d/010wheel":
        owner => root,
        group => root,
        mode => 0440,
        content => "$puphead\n\n%wheel ALL=(ALL) ALL\n"
    }

}

