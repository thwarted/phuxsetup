
# manages an iptables table of puppet-specified and managed filter rules
#
# if the title matches s/proto, then 
# netfilter::rule { "22/tcp": action=>"ACCEPT" }
#
# iptables can use getservbyname
# netfilter::rule { "tftp/udp": action=>"ACCEPT" }
#
# explicitly give a list of ports
# netfilter::rule { "web": port=>"80,443", action=>"ACCEPT" }

define netfilter::rule(
    $port="unspecified",
    $order=999,
    $proto="tcp",
    $action="ACCEPT",
    $desc=false,
    $srcip=false,
    $destip=false,
    $inface=false,
    $outface=false,
) {

    if $inface  { $infacex  = "-i $inface"  } else { $infacex  = "" }
    if $outface { $outfacex = "-o $outface" } else { $outfacex = "" }

    if $srcip {
        if is_ip_address($srcip) {
            $srcipx = "-s $srcip"
        } else {
            $errors += "netfilter::rule iptables $title: source $srcip does not appear to be an ip address"
        }
    } else {
        $srcipx  = ""
    }

    if $destip {
        if is_ip_address($destip) {
            $destipx = "-s $destip"
        } else {
            $errors += "netfilter::rule $title: destination $destip does not appear to be an ip address"
        }
    } else {
        $destipx  = ""
    }

    case $title {
        /^(\w+)\x2f(\w+)$/: {
                                $portx = sprintf("--dport %s", $1)
                                $protox = $2
                            }
        default: {  $protox = $proto
                    case $port {
                        /,/: { $portx = "-m multiport --dports $port" }
                        "unspecified": { $errors += "netfilter::rule $title: illegal port specified" }
                        default: { $portx = "--dport $port" }
                    }
        }
    }

    $filename = sprintf("%03dpuppet_%s", $order, sha1($title))

    if !$errors {
        if !defined(File['/tmp/iptables.out/000preamble']) {
            file { "/tmp/iptables.out":
                ensure => directory,
                backup => false,
                purge => true,
                recurse => true,
                before => File['/tmp/iptables.out/000preamble']
            }
            file { '/tmp/iptables.out/000preamble':
                # content => "*filter\n:puppet-new - [0:0]\n",
                content => "iptables -N puppet-new\n",
                before => Exec['netfilter::build'],
                require => Exec['netfilter::setup']
            }
            file { '/tmp/iptables.out/ZZZpostamble':
                #content => "COMMIT\n",
                content => "\n",
                before => Exec['netfilter::build'],
                require => Exec['netfilter::setup']
            }
            exec { "netfilter::setup":
                path => "/sbin:/usr/sbin:/bin:/usr/bin",
                command => "iptables -F puppet-new ; iptables -X puppet-new ; iptables -F puppet-old ; iptables -X puppet-old ; iptables -N puppet ; /bin/true"
            }
            exec { "netfilter::build":
                path => "/sbin:/usr/sbin:/bin:/usr/bin",
                command => "cat /tmp/iptables.out/* | sh",
                require => Exec['netfilter::setup'],
                before => Exec["netfilter::swap"]
            }
            exec { "netfilter::swap":
                path => "/sbin:/usr/sbin:/bin:/usr/bin",
                command => "iptables -A INPUT -j puppet-new ; 
                            iptables --rename-chain puppet puppet-old ; 
                            iptables --rename-chain puppet-new puppet ; 
                            iptables -D INPUT -j puppet-old ; 
                            iptables -F puppet-old ; iptables -X puppet-old",
                require => Exec["netfilter::build"]
            }
        }
        $comment = sprintf("%s, order %03d", $title, $order)
        file { "/tmp/iptables.out/${filename}":
            content => "iptables -A puppet-new $infacex $outfacex $srcipx $destipx -p $protox $portx -m state --state NEW -j $action -m comment --comment \"$comment\"\n",
            require => Exec['netfilter::setup'],
            before => Exec['netfilter::build']
        }
    } else {
        notify { $errors: }
    }

}



netfilter::rule { "http-internal": port=>"80,443" }
netfilter::rule { "http-external": port=>"80,443", srcip=>"10.0.0.0/8", action=>"REJECT", order=>1 }
netfilter::rule { "ssh/tcp": action=>"ACCEPT" }
