
class authentication::pamdsudo {

    packages::deppack { "pamsshagent": }

    file { "/etc/pam.d/sudo":
        owner => root,
        group => root,
        mode => 0644,
        source => "puppet:///modules/authentication/etc/pam.d/sudo",
        require => Packages::Deppack['pamsshagent']
    }

}

