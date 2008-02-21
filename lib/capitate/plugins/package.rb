# Package plugin.
#
# TODO: If type not set silently fails. NOT GOOD :(
#
module Capitate::Plugins::Package
  
  # Setup packager.
  #
  # ==== Options
  # +packager_type+:: Packager type (:yum)
  #
  # ==== Examples (in capistrano task)
  #   package.type = :yum
  #   package.install [ "aspell", "foo" ]
  #   package.remove [ "aspell", "foo" ]
  #   package.update [ "aspell", "foo" ]
  #   package.clean
  #
  def type=(packager_type)
    case packager_type.to_sym
    when :yum
      include Capitate::Plugins::Yum
    else
      raise "Invalid packager type: #{packager_type}"
    end    
  end  
    
end

Capistrano.plugin :package, Capitate::Plugins::Package