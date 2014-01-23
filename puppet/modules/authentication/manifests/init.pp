
class authentication {

    # we remove this package
    exec { "disable fingerprint auth":
        command => "/usr/sbin/authconfig --disablefingerprint --update ; /bin/touch /tmp/disable-fingerprint",
        creates => "/tmp/disable-fingerprint",
    }

}
