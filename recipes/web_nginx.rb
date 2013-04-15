case node['platform']
when "ubuntu","debian"
  %w{ php5-mysql php5-gd }.each do |pck|
    package pck do
      action :install
      notifies :restart, "service[nginx]"
    end
  end

when "redhat","centos","scientific","amazon","oracle"

  if node['platform_version'].to_f < 6.0
    %w{ php53-mysql php53-gd php53-bcmath php53-mbstring }.each do |pck|
      package pck do
        action :install
        notifies :restart, "service[nginx]"
      end
    end
  else
    %w{ php-mysql php-gd php-bcmath php-mbstring }.each do |pck|
      package pck do
        action :install
        notifies :restart, "service[nginx]"
      end
    end
  end

end

zabbix_source "extract_zabbix_web" do
  branch              node['zabbix']['server']['branch']
  version             node['zabbix']['server']['version']
  code_dir            node['zabbix']['src_dir']
  target_dir          "zabbix-#{node['zabbix']['server']['version']}"  
  install_dir         node['zabbix']['install_dir']

  action :extract_only

end

# Link to the web interface version
link node['zabbix']['web_dir'] do
  to "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php"
end

conf_dir = ::File.join(node['zabbix']['src_dir'], "zabbix-#{node['zabbix']['server']['version']}", "frontends", "php", "conf") 
directory conf_dir do
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0755"
  action :create
end

# install zabbix PHP config file
template ::File.join(conf_dir, "zabbix.conf.php") do
  source "zabbix_web.conf.php.erb"
  owner "root"
  group "root"
  mode "754"
end

# install host for zabbix
template "/etc/nginx/sites-available/zabbix" do
  source "zabbix_nginx.erb"
  owner "root"
  group "root"
  mode "754"
  variables ({
    :php_settings => node['zabbix']['web']['php_settings'],
    :web_port => node['zabbix']['web']['port'],
    :web_dir => node['zabbix']['web_dir']
  })
  notifies :restart, "service[php-fpm]", :delayed
end

#create a symlink
link "/etc/nginx/sites-enabled/zabbix" do
  to "/etc/nginx/sites-available/zabbix"
end

#remove default
link "/etc/nginx/sites-enabled/000-default" do
  action :delete
end

file "/etc/nginx/conf.d/default.conf" do
  action :delete
end
