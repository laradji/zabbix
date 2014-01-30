# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: web
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::common"

include_recipe "apache2"
include_recipe "apache2::mod_php5"

service 'php5-fpm' do
  action [ :disable, :stop ]
end

service 'apache2' do
  action [ :enable, :start ]
end


directory node['zabbix']['install_dir'] do
  mode "0755"
end

node.normal['zabbix']['web']['fqdn'] = node['fqdn'] if node['zabbix']['web']['fqdn'].nil?
unless node['zabbix']['web']['user']
  node.normal['zabbix']['web']['user'] = "www-data"
end

apps = []
search(:apps) do |app|
  (app["server_roles"] & node.run_list.roles).each do |app_role|
    #db << data_bag_item("apps",app)
    apps << app
  end
end

bindip=""
bindport=""
apps.each do |a|
  if a['bind'] && a['bind'][node.chef_environment] && a['bind'][node.chef_environment]['ip'] 
    node.normal['zabbix']['web']['ip'] = a['bind'][node.chef_environment]['ip']
    bindip =  a['bind'][node.chef_environment]['ip']
  else
    node.normal['zabbix']['web']['ip'] = (node["cloud"]) ? node["cloud"]["local_ipv4"] : node["ipaddress"]
    bindip = (node["cloud"]) ? node["cloud"]["local_ipv4"] : node["ipaddress"]
  end

  bindport = node['zabbix']['web']['port'] 
  if a['bind'] && a['bind'][node.chef_environment] && a['bind'][node.chef_environment]['port'] 
    node.normal['zabbix']['web']['port'] = a['bind'][node.chef_environment]['port']
    bindport =  a['bind'][node.chef_environment]['port']
  end
end

user node['zabbix']['web']['user']

case node['platform_family']
when "debian"
  %w{ php5-mysql php5-gd }.each do |pck|
    package pck do
      action :install
      notifies :restart, "service[apache2]"
    end
  end
when "rhel"
  if node['platform_version'].to_f < 6.0
    %w{ php53-mysql php53-gd php53-bcmath php53-mbstring }.each do |pck|
      package pck do
        action :install
        notifies :restart, "service[apache2]"
      end
    end
  else
    %w{ php php-mysql php-gd php-bcmath php-mbstring php-xml }.each do |pck|
      package pck do
        action :install
        notifies :restart, "service[apache2]"
      end
    end
  end
end

zabbix_source "extract_zabbix_web" do
  branch              node['zabbix']['server']['branch']
  version             node['zabbix']['server']['version']
  source_url          node['zabbix']['server']['source_url']
  code_dir            node['zabbix']['src_dir']
  target_dir          "zabbix-#{node['zabbix']['server']['version']}"  
  install_dir         node['zabbix']['install_dir']

  action :extract_only

end

link node['zabbix']['web_dir'] do
  to "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php"
end

directory "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php/conf" do
  owner node['apache']['user']
  group node['apache']['group']
  mode "0755"
  action :create
end

# install zabbix PHP config file
template "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php/conf/zabbix.conf.php" do
  source "zabbix_web.conf.php.erb"
  owner "root"
  group "root"
  mode "754"
  variables({
    :database => node['zabbix']['database'],
    :server => node['zabbix']['server']
  })
end

# install vhost for zabbix frontend
web_app node['zabbix']['web']['fqdn'] do
  server_name node['zabbix']['web']['fqdn']
  server_aliases node['zabbix']['web']['aliases']
  docroot node['zabbix']['web_dir']
  only_if { node['zabbix']['web']['fqdn'] != nil }
  php_settings node['zabbix']['web']['php']['settings']
  bindip bindip
  bindport bindport
  notifies :restart, "service[apache2]", :immediately 
end  

apache_site "000-default" do
  enable false
end
