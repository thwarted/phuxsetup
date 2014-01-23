require 'etc'

Facter.add("allusers") do
    setcode do
        users = []
        Etc.passwd {|u|
            users << u.name
        }
        users.sort!.join(":")
    end
end
