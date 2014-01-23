
class authentication::sshd {
    service { "sshd":
        ensure => "running",
        enable => true,
    }

    file { "/etc/ssh/sshd_config":
        owner => root,
        group => root,
        mode => 0600,
        source => $is_vagrant ? {
               true => "puppet:///modules/authentication/etc/ssh/sshd_config.vagrant",
            default => "puppet:///modules/authentication/etc/ssh/sshd_config",
        },
        notify => Service['sshd']
    }

}
