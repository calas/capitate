module Capitate::Plugins::Templates
  
  # Get the absolute base templates path.
  def gem_templates_root
    File.expand_path(File.dirname(__FILE__) + "/../../templates")
  end
  
  # Get full template path from relative path.
  #
  # Something like <tt>monit/monit.cnf => /usr/lib/..../capitate/lib/templates/monit/monit.cnf</tt>.
  #
  # ==== Options 
  # +template_path+:: Relative path
  #
  def gem_template_path(template_path)
    File.join(gem_templates_root, template_path)
  end
  
  # Load template. If extension is erb will be evaluated with binding.
  # 
  # ==== Options
  # +path+:: If starts with '/', absolute path, otherwise relative path to templates dir
  # +override_binding+:: Binding to override, otherwise uses current (task) binding
  #
  # ==== Examples
  #   template.load("memcached/memcached.monitrc.erb")
  #   put template.load("memcached/memcached.monitrc.erb"), "/tmp/memcached.monitrc"
  #
  def load(path, override_binding = nil)
    template_paths = [ path, gem_template_path(path) ]
    
    template_paths = template_paths.select { |file| File.exist?(file) }
    
    if template_paths.empty?
      raise <<-EOS 
      
      
      Template not found: #{path}
      
      EOS
    end
    
    # Use first
    template_path = template_paths.first
    
    template_data = IO.read(template_path)
    
    if File.extname(template_path) == ".erb"    
      template = ERB.new(template_data)
      template_data = template.result(override_binding || binding)
    end
    template_data
  end
  
  # Load template from project.
  # If extension is erb will be evaluated with binding.
  # 
  # ==== Options
  # +path+:: If starts with '/', absolute path, otherwise relative path to templates dir
  # +override_binding+:: Binding to override, otherwise uses current (task) binding
  #
  # ==== Examples
  #   template.project("config/templates/sphinx.conf.erb")
  #   put template.project("config/templates/sphinx.conf.erb"), "#{shared_path}/config/sphinx.conf"
  #
  def project(path, override_binding = nil)
    load(project_root + "/" + path, override_binding || binding)
  end
    
  # Write template at (relative path) with binding to LOCAL destination path.
  #
  # ==== Options
  # +template_path+:: Path to template relative to templates path
  # +dest_path+:: Local destination path to write to
  # +overwrite_binding+:: Binding  
  # +overwrite+:: Force overwrite
  # +verbose+:: Verbose output
  #
  # ==== Examples
  #   template.write("config/templates/sphinx.conf.erb", binding, "config/sphinx.conf")
  #  
  def write(template_path, dest_path, override_binding = nil, overwrite = false, verbose = true)    
    # This is gnarly!
    relative_dest_path = Pathname.new(File.expand_path(dest_path)).relative_path_from(Pathname.new(File.expand_path(".")))  
    
    if !overwrite && File.exist?(dest_path) 
      puts "%10s %-40s (skipped)" % [ "create", relative_dest_path ] if verbose
      return
    end
    
    puts "%10s %-40s" % [ "create", relative_dest_path ] if verbose
    template_data = load(template_path, override_binding)
    File.open(dest_path, "w") { |file| file.puts(load(template_path, override_binding)) }
  end
    
end

Capistrano.plugin :template, Capitate::Plugins::Templates