require 'puppet/parser/files'

module Puppet::Parser::Functions
    newfunction(:user_exists, :type => :rvalue) do |user|
        # been bitten by this, puppet seems inconsistent in what it passes for the first arg
        if user.is_a?(Array)
            user = user[0]
        end

        allusers = lookupvar("allusers")
        if allusers.empty? or allusers.nil?
            self.fail("facter did not set allusers")
        end

        if /\b#{Regexp.quote(user)}\b/.match(allusers)
            user
        else
            false
        end
    end
end
