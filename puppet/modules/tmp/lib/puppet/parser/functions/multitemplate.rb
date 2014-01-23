require 'find'
require 'fileutils'
require 'puppet/parser/files'

# this function requires a writable directory on the puppetmaster at
# $confdir/modules/tmp/files
# this can be a symlink to elsewhere in the filesystem if your puppet confdir
# is not writable by the user puppetmaster runs as.
# this will recurse over the provided templatepath:
#   if the filename ends in .erb, it will template it
#   if it's a directory or doesn't end in .erb, it will copy it
# the resultant files will be put in a temporary directory accessbile via
# the writable path above, and this will return a puppet:///modules/tmp/
# so the client can access the templated files
# Use exactly as you would the template() function in a file{} stanza:
#
#    file { "/etc/somedir":
#        owner => abc,
#        group => def,
#        mode => 0755,
#        recurse => true,
#        purge => true,
#        source => multitemplate("modulename/abc")
#    }
# Note that "modulename/abc" is really modules/modulename/templates/abc
# in your confdir (per puppet's module search/resolution method)

module Puppet::Parser::Functions
    newfunction(:multitemplate, :type => :rvalue) do |root|
        # Some versions of puppet pass an array if there's 1 argument, some just pass the argument.
        if root.is_a?(Array)
            root = root[0]
        end

        temlate_temp_dir = File.join(Puppet.settings[:confdir], "modules", "tmp", "files")

        if ! File.directory?(temlate_temp_dir) || ! File.writable?(temlate_temp_dir)
            raise(Puppet::ParseError, "#{temlate_temp_dir} is not writable on the puppetmaster, can not process multitemplate")
        end

        clean_root = root.sub('/', '_')
        source_dir = Puppet::Parser::Files.find_template(root)

        while true do
            unique = '123456789A'.split('').map{(rand(26)+65).chr}.join('')
            target_dir = File.join(temlate_temp_dir, "#{clean_root}_#{unique}")
            if File.directory?(target_dir)
                Puppet.notice("found already existing temp dir #{target_dir}")
            else
                break
            end
        end

        Puppet.notice("recursively templating #{source_dir} (#{root}) into #{target_dir}")
        FileUtils.mkdir_p(target_dir)

        Find.find(source_dir) { |path|
            if path == source_dir
                next
            end
            if File.directory?(path)
                FileUtils::mkdir(File.join(target_dir, path.sub(source_dir, '')))
            elsif path =~ /\.erb$/
                path.sub!(source_dir, '')
                templater = Puppet::Parser::TemplateWrapper.new(self)
                templater.file = File.join(root, path)
                begin
                    val = templater.result
                    newfile = File.join(target_dir, path.sub(/\.erb$/, ''))
                    File.open(newfile, 'w') { |f|
                        f.write(val)
                    }
                rescue => e
                    raise(Puppet::ParseError, "Failed to parse template %s: %s" % [templater.file, e])
                end
            else
                path.sub!(source_dir, '')
                FileUtils.cp(File.join(source_dir, path), File.join(target_dir, path), :preserve => true)
            end
        }

        "puppet:///modules/tmp/#{clean_root}_#{unique}"
    end
end
