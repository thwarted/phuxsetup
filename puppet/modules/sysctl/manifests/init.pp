#
# sysctl { "net.ipv4.ip_forward":
#       value => 1,
#       priority => 90,
#       oldpriority => 20,
# }
#
# Set net.ipv4.ip_forward to 1, write a configuration file to /etc/sysctl.d
# inserted in the order at $priority.  If $oldpriority is given, remove
# a file file that may be exist at the given $oldpriority in /etc/sysctl.d
#

define sysctl(
    $value,
    $priority=90,
    $oldpriority=false,
) {

    case $title {
        /^[-0-9a-zA-Z._]+$/: { $_sysctl_name = $title }
        default: { err("invalid character in sysctl variable") }
    }

    if $value == false {
        $_sysctl_value = false
    } else {
        case $value {
            /^[-0-9a-zA-Z \t]+$/: { $_sysctl_value = sysctl_normalize($value) }
            default: { err("invalid character in sysctl value") }
        }
    }

    if ($_sysctl_name) {

        $_sysctl_filename = sprintf("/etc/sysctl.d/%03d-$_sysctl_name.conf", $priority)
        if ($oldpriority) {
            $_sysctl_oldfilename = sprintf("/etc/sysctl.d/%03d-$_sysctl_name.conf", $oldpriority)
            file { $_sysctl_oldfilename: ensure => absent }
        }

        if $_sysctl_value {

            if !defined(File["/etc/sysctl.d"]) {
                file { "/etc/sysctl.d": ensure => directory, mode => 0755, owner => root, group => root }
            }

            file { $_sysctl_filename:
                mode => 0444,
                owner => root,
                group => root,
                content => "# this file is managed by puppet\n$_sysctl_name=$_sysctl_value\n"
            }

            $_sysctl_current = sysctl_normalize(getvar("sysctl.$_sysctl_name"))
            if $_sysctl_current != $_sysctl_value {
                notify { "Changing sysctl $_sysctl_name from \"$_sysctl_current\" to \"$_sysctl_value\"": }
                exec { "sysctl-$_sysctl_name":
                    path => "/sbin",
                    logoutput => true,
                    command => "sysctl -p $_sysctl_filename",
                    require => File[$_sysctl_filename]
                }
            }
        } else {
            file { $_sysctl_filename: ensure => absent }
        }
    }
}
