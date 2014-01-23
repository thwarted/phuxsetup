
require 'puppet/parser/files'
require 'digest/md5'

module Puppet::Parser::Functions
    newfunction(:genuserid, :type => :rvalue) do |username|
        # Some versions of puppet pass an array if there's 1 argument, some
        # just pass the argument.
        if username.is_a?(Array)
            username = username[0]
        end

        uid = Integer("0x"+Digest::MD5.hexdigest(username)[0..3])
        # TODO add more sanity checks
        #  - isn't already assigned to a currently existing user or group
        #  - if it is assigned, the username matches
        #  - if username is 'root', force return 0 ?
        # TODO keep trying to generate unique values
        if uid < 1000
            # TODO add 1000 ?
            self.fail("generated uid for "+username+" is less than 1000")
        end
        uid
    end
end

