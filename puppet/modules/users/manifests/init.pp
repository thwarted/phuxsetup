
class users {
    include user_abakun
}

class user_abakun {
    users::user { "abakun":
        comment => "Andy Bakun",
        groups => ['wheel']
    }

    file { "/home/abakun/.vim":
        source => "puppet:///modules/users/home/abakun/.vim",
        ensure => directory,
        recurse => true,
        purge => false,
        owner => abakun, group => abakun, mode => 0644,
        require => Users::User['abakun']
    }
    file { "/home/abakun/.vimrc":
        source => "puppet:///modules/users/home/abakun/.vimrc",
        owner => abakun, group => abakun, mode => 0644,
        require => Users::User['abakun']
    }
    file { "/home/abakun/.tmux.conf":
        source => "puppet:///modules/users/home/abakun/.tmux.conf",
        owner => abakun, group => abakun, mode => 0644,
        require => Users::User['abakun']
    }
}

