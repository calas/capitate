# Nginx recipes
namespace :nginx do
  
  desc <<-DESC 
  Install nginx monit hooks.
  
  nginx_pid_path: Path to nginx pid file. Defaults to /var/run/nginx.pid    
  
    set :nginx_pid_path, "/var/run/nginx.pid"
    
  DESC
  task :install_monit do
    
    # Settings
    fetch_or_default(:nginx_pid_path, "/var/run/nginx.pid")
    
    put template.load("nginx/nginx.monitrc.erb", binding), "/tmp/nginx.monitrc"    
    sudo "install -o root /tmp/nginx.monitrc /etc/monit/nginx.monitrc"
  end
    
  desc <<-DESC
  Create and update the nginx vhost include.
  
  mongrel_size: Number of mongrels.    
  
    set :mongrel_size, 3
    
  mongrel_port: Starting port for mongrels.
  If there are 3 mongrels with port 9000, then instances will be at 9000, 9001, and 9002    
  
    set :mongrel_port, 9000

  domain_name: Domain name for nginx virtual host, (without www prefix).    
  
    set :domain_name, "foo.com"
    
  DESC
  task :setup_mongrel do 
    after "nginx:setup_mongrels", "nginx:restart"
    
    # Settings
    fetch(:mongrel_size)
    fetch(:mongrel_port)
    fetch(:domain_name)
    
    set :ports, (0...mongrel_size).collect { |i| mongrel_port + i }
    set :public_path, current_path + "/public"
    
    run "mkdir -p #{shared_path}/config"
    put template.load("nginx/nginx_vhost.conf.erb"), "/tmp/nginx_#{application}.conf"    
    
    sudo "install -o root /tmp/nginx_#{application}.conf /etc/nginx/vhosts/#{application}.conf"        
  end
    
  # Restart nginx
  task :restart do
    # TODO: Monit
    sudo "/sbin/service nginx restart"
  end
    
end