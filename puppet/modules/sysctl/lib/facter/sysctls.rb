require 'facter'

# note that the keys of these values have embedded dots, so
# they can not be used directly in puppet (since variables in puppet
# have a limited character set). Use getvar from stdlib to get the
# values

IO.popen("/sbin/sysctl -a 2>/dev/null") { |p|
    while (f = p.gets) do
        f.chomp!
        k,v = f.split(" = ", 2)
        v ||= ""
        v.gsub!("\t", " ")
        Facter.add("sysctl."+k) do
            x = v
            # setcode is dangerous. If passed a string
            # as the first argument, it will execute that string
            # through the shell, so this needs to be a block
            # that emits the value of x from the enclosing scope.
            setcode do
                x
            end
        end
    end
}

# Return all sysctls in a JSON formatted string
#require 'json'
#Facter.add("sysctl") do
#    setcode do
#        ret = {}
#        IO.popen("/sbin/sysctl -a 2>/dev/null") { |p|
#            c = 0
#            while (f = p.gets) and c < 10 do
#                f.chomp!
#                k,v = f.split(" = ", 2)
#                v.gsub!("\t", " ")
#                ret[k] = v
#                c = c + 1
#            end
#        }
#        ret.to_json
#    end
#end

