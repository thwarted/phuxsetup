define yum-plugin($enabled=true) {
    # the yum pluginconf.d file is put in place to enable the
    # plugin if it is installed
    # TODO emit a warning if the dependent package isn't installed?
    if $enabled {
        file { "/etc/yum/pluginconf.d/$title.conf":
            owner => root,
            group => root,
            mode => 0644,
            content => "[main]\nenabled = 1\n",
        }
    } else {
        file { "/etc/yum/pluginconf.d/$title.conf":
            ensure => absent
        }
    }
}


class packages {

    yum-plugin { "priorities": }
    yum-plugin { "protectbase": }

}

