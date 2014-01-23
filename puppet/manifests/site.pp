
import "globals.pp"
import "nodes/*.pp"

node default {
    notify { "default node assigned": }

    include users
    include authentication::pamdsudo
    include authentication::sudoers
    include authentication::sshd

    include server
}

