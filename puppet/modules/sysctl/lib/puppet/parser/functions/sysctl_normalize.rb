#
# sysctl_normalize.rb
#

module Puppet::Parser::Functions
  newfunction(:sysctl_normalize, :type => :rvalue, :doc => <<-EOS
Normalizes a string that is meant to be a value for a sysctl.
    EOS
	) do |arguments|

        raise(Puppet::ParseError, "sysctl_normalize(): Wrong number of arguments " +
              "given (#{arguments.size} for 1)") if arguments.size != 1

        value = arguments[0].to_s

        value.gsub(/\s+/, " ").strip
    end
end
