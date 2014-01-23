require 'etc'

Facter.add("allgroups") do
    setcode do
        groups = []
        Etc.group {|g|
            groups << g.name
        }
        groups.sort!.join(":")
    end
end
