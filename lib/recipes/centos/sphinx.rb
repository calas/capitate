namespace :centos do
  
  namespace :sphinx do
    
    desc <<-DESC
    Install sphinx.
    
    sphinx_prefix: Sphinx install prefix. Defaults to "/usr/local/sphinx"
    
      set :sphinx_prefix, "/usr/local/sphinx"
      
    DESC
    task :install do 
      
      # Settings
      fetch_or_default(:sphinx_prefix, "/usr/local/sphinx")
      
      # Install dependencies
      yum.install([ "gcc-c++" ])
      
      # Build options
      sphinx_options = {
        :url => "http://www.sphinxsearch.com/downloads/sphinx-0.9.7.tar.gz",
        :configure_options => "--with-mysql-includes=/usr/include/mysql --with-mysql-libs=/usr/lib/mysql \
  --prefix=#{sphinx_prefix}"
      }
      
      # Build
      script.make_install("sphinx", sphinx_options)
    end
        
    desc <<-DESC
    Setup sphinx for application.
    
    sphinx_prefix: Sphinx install prefix. Defaults to "/usr/local/sphinx"
    
      set :sphinx_prefix, "/usr/local/sphinx"
      
    DESC
    task :setup do 
      after "centos:sphinx:setup", "sphinx:setup_monit"
      
      # Settings
      fetch_or_default(:sphinx_prefix, "/usr/local/sphinx")

      # Derived settings
      set :sphinx_bin_path, "#{sphinx_prefix}/bin"
      set :sphinx_conf_path, "#{shared_path}/config/sphinx.conf"
      set :sphinx_pid_path, "#{shared_path}/pids/searchd.pid"

      # Install initscript
      put template.load("sphinx/sphinx_app.initd.centos.erb"), "/tmp/sphinx.initd"
      sudo "install -o root /tmp/sphinx.initd /etc/init.d/sphinx_#{application}"

      # Enable service
      sudo "/sbin/chkconfig --level 345 sphinx_#{application} on"    

      # Create app indexes dir
      run "mkdir -p #{shared_path}/var/index"    
    end
  end
  
end