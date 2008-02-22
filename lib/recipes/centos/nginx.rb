namespace :centos do 
  
  namespace :nginx do
    
    desc <<-DESC
    Install nginx, conf, initscript, nginx user and service.
    nginx_bin_path: Nginx sbin path. Defaults to /sbin/nginx
    
      set :nginx_bin_path, "/sbin/nginx"

    nginx_conf_path: Path to nginx conf. Defaults to /etc/nginx/nginx.conf
    
      set :nginx_conf_path, "/etc/nginx/nginx.conf"

    nginx_pid_path: Path to nginx pid file. Defaults to /var/run/nginx.pid
    
      set :nginx_pid_path, "/var/run/nginx.pid"

    nginx_prefix_path: Nginx install prefix. Defaults to /var/nginx
    
      set :nginx_prefix_path, "/var/nginx"
      
    DESC
    task :install do
      
      # Settings
      fetch_or_default(:nginx_bin_path, "/sbin/nginx")
      fetch_or_default(:nginx_conf_path, "/etc/nginx/nginx.conf")
      fetch_or_default(:nginx_pid_path, "/var/run/nginx.pid")
      fetch_or_default(:nginx_prefix_path, "/var/nginx")      
            
      # Install dependencies
      yum.install([ "pcre-devel", "openssl", "openssl-devel" ]) 
            
      # Build options
      nginx_options = {
        :url => "http://sysoev.ru/nginx/nginx-0.5.35.tar.gz",
        :configure_options => "--sbin-path=#{nginx_bin_path} --conf-path=#{nginx_conf_path} \
--pid-path=#{nginx_pid_path} --error-log-path=/var/log/nginx_master_error.log --lock-path=/var/lock/nginx \
--prefix=#{nginx_prefix_path} --with-md5=auto/lib/md5 --with-sha1=auto/lib/sha1 --with-http_ssl_module"
      }

      # Build
      script.make_install("nginx", nginx_options)

      # Install initscript, and turn it on
      put template.load("nginx/nginx.initd.erb"), "/tmp/nginx.initd"
      sudo "install -o root /tmp/nginx.initd /etc/init.d/nginx && rm -f /tmp/nginx.initd"
      sudo "/sbin/chkconfig --level 345 nginx on"

      # Setup nginx
      sudo "mkdir -p /etc/nginx/vhosts"
      sudo "echo \"# Blank nginx conf; work-around for nginx conf include issue\" > /etc/nginx/vhosts/blank.conf"
      put template.load("nginx/nginx.conf.erb", binding), "/tmp/nginx.conf"
      sudo "install -o root -m 644 /tmp/nginx.conf #{nginx_conf_path} && rm -f /tmp/nginx.conf"

      # Create nginx user
      sudo "id nginx || /usr/sbin/adduser -r nginx"
    end
    
  end
  
end