
# creates UPG for the user also
# if the user exists but is disabled, we don't delete the account


define users::user_manage(
    $home,
    $keyfile
) {
    $username = $title

    if !defined(File["/etc/authorized_keys.d"]) {
        file { "/etc/authorized_keys.d":
            ensure => 'directory',
            owner => root,
            group => root,
            mode => 0755,
        }
    }

    realize(Group[$username])
    realize(User[$username])
    realize(File[$home])
    realize(File["$home/.ssh"])
    realize(File["$home/.ssh/README"])
    realize(File[$keyfile])
}

define users::user(
    $uid=false,
    $comment,
    $password="*", 
    $home='',
    $shell='/bin/bash',
    $enabled=true,
    $groups=[],
    $authorized_keys_file=''
) {
    # set authorized_keys_file to "none" to disable all remote access

    # `passwd -S` interprets the password field
    #  * = Alternate authentication scheme in use
    #  ! = Locked account

    $username = $title
    if $home {
        $homex = $home
    } else {
        $homex = "/home/${username}"
    }

    # TODO check for non-existence or matches username here
    # to avoid clobbering already existing accounts in case
    # genuserid isn't unique enough (?!?)
    if $uid {
        $uidx = $uid
    } else {
        $uidx = genuserid($username)
    }

    $sshdir = "${homex}/.ssh"
    $keyfile = "/etc/authorized_keys.d/${username}.pub"

    if !$authorized_keys_file {
        $keysource = "puppet:///modules/users/authorized_keys.d/${username}.pub"
    } else {
        $keysource = $authorized_keys_file
    }

    if $enabled {
        $shellx = $shell
        $passwordx = $password
        $groupsx = $groups
        if $keysource == "none" {
            @file { "$keyfile":
                ensure => absent,
            }
        } else {
            @file { "$keyfile":
                # we want root to own the the files in /etc/authorized_keys.d, since
                # sudo will use them for authentication too
                owner => 'root',
                group => 'root',
                mode => 0644,
                source => $keysource,
                # implicitly requires File['/etc/authorized_keys.d']
            }
        }
    } else {
        $shellx = "/sbin/nologin"
        $passwordx = $password ? {
            /^!/ => $password,
            default => "!${password}"
        }
        $groupsx = []
        @file { "$keyfile":
            ensure => absent
        }
    }

    # in UPG, uid and gid *should* match

    @group { $username:
        ensure => 'present',
        gid => $uidx,
    }

    @user { $username:
        ensure => 'present',
        uid => $uidx,
        gid => $uidx,
        groups => $groupsx,
        comment => $comment,
        membership => 'inclusive',
        home => $homex,
        shell => $shellx,
        password => $passwordx
    }

    @file { $homex:
        ensure => 'directory',
        owner => $username,
        group => $username,
        mode => 0755,
    }

    @file { "$sshdir":
        ensure => 'directory',
        owner => $username,
        group => $username,
        mode => 0755,
    }

    @file { "$sshdir/README":
        owner => $username,
        group => $username,
        mode => 0644,
        content => "authorized_keys is managed with puppet, and is not read from this directory\n"
    }

    # if the user doesn't exist and is disabled, don't create the account
    # just to disable it
    if $enabled or user_exists($username) {
        users::user_manage { $username:
            home => $homex,
            keyfile => $keyfile,
        }
        notice("managing user $username")
    } else {
        notice("no need to manage $username, disabled and does not exist")
    }
}

