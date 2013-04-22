# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: web
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

node.set['zabbix']['web']['fqdn'] = node['fqdn'] if node['zabbix']['web']['fqdn'].nil?

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
    %w{ php-mysql php-gd php-bcmath php-mbstring php-xml }.each do |pck|
      package pck do
        action :install
        notifies :restart, "service[apache2]"
      end
    end
  end
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
end

# install vhost for zabbix frontend
web_app node['zabbix']['web']['fqdn'] do
  server_name node['zabbix']['web']['fqdn']
  server_aliases node['zabbix']['web']['aliases']
  docroot node['zabbix']['web_dir']
  only_if { node['zabbix']['web']['fqdn'] != nil }
  php_settings node['zabbix']['web']['php_settings']
end  

apache_site "000-default" do
  enable false
end
