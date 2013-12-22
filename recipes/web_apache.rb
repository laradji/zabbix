# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: web
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::common"


node.normal['zabbix']['web']['fqdn'] = node['fqdn'] if node['zabbix']['web']['fqdn'].nil?
unless node['zabbix']['web']['user']
  node.normal['zabbix']['web']['user'] = "apache"
end

user node['zabbix']['web']['user']

if node['zabbix']['web']['install_package']
  include_recipe "zabbix::_repository"
  case node['platform_family']
  when "debian"
    package "zabbix-frontend-php" do
      action :install
    end
    case node['zabbix']['database']['install_method']
    when "mysql"
      package "php5-mysql" do
        action :install
      end
    when "postgres"
      package "php5-pgsql" do
        action :install
      end
    end
  when "rhel"
    
    engine = case node['zabbix']['database']['install_method']
             when "mysql"
               "-mysql"
             when "postgres"
               "-pgsql"
             else
               ""
             end

    package "zabbix-web#{engine}" do
      action :install
    end
  end
  conf_dir = "/etc/zabbix/web"
  
else

  directory node['zabbix']['install_dir'] do
    mode "0755"
  end
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
  
  php_dir = "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php"
  conf_dir = "#{php_dir}/conf"
  link node['zabbix']['web_dir'] do
    to php_dir
  end
  
  directory conf_dir do
    owner node['apache']['user']
    group node['apache']['group']
    mode "0755"
    action :create
  end
end

# install zabbix PHP config file
template "#{conf_dir}/zabbix.conf.php" do
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
  notifies :restart, "service[apache2]", :immediately 
end  

apache_site "000-default" do
  enable false
end
