
if $virtual == 'virtualbox' and user_exists('vagrant') {
    $is_vagrant = true
} else {
    $is_vagrant = false
}

File {
    backup => false,
}

# purge old clientbucket stuff and only keep new (explicitly backed-up) files for a short period
tidy { "clean_clientbucket":
    backup => false,
    path => '/var/lib/puppet/clientbucket',
    recurse => true,
    rmdirs => true,
    age => '2d',
    type => 'atime',
}

Exec {
    path => "/usr/bin:/bin:/usr/sbin:/sbin" 
}
