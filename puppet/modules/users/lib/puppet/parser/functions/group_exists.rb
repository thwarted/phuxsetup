
require 'puppet/parser/files'

module Puppet::Parser::Functions
    newfunction(:group_exists, :type => :rvalue) do |group|
        # been bitten by this, puppet seems inconsistent in what it passes for the first arg
        if group.is_a?(Array)
            group = group[0]
        end

        allgroups = lookupvar("allgroups")
        if allgroups.empty? or allgroups.nil?
            self.fail("facter did not set allgroups")
        end

        if /\b#{Regexp.quote(group)}\b/.match(allgroups)
            group
        else
            false   
        end
    end    
end   

