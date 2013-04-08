# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::default"

case node['platform']
when "ubuntu","debian"
  # install some dependencies
  %w{ fping libmysql++-dev libmysql++3 libcurl3 libiksemel-dev libiksemel3 libsnmp-dev snmp libiksemel-utils libcurl4-openssl-dev }.each do |pck|
    package pck do
      action :install
    end
  end
  init_template = 'zabbix_server.init.erb'
when "redhat","centos","scientific","amazon","oracle"
    if node['platform_version'].to_i < 6
      curldev = 'curl-devel'
    else
      curldev = 'libcurl-devel'
    end
    %w{ fping mysql-devel iksemel-devel iksemel-utils net-snmp-libs net-snmp-devel openssl-devel redhat-lsb }.push(curldev).each do |pck|
      package pck do
        action :install
      end
    end
  init_template = 'zabbix_server.init-rh.erb'
end

configure_options = (node['zabbix']['server']['configure_options'] || Array.new).delete_if do |option|
  option.match(/\s*--prefix(\s|=).+/)
end
node.set['zabbix']['server']['configure_options'] = configure_options

zabbix_source "install_zabbix_server" do
  branch              node['zabbix']['server']['branch']
  version             node['zabbix']['server']['version']
  code_dir            node['zabbix']['src_dir']
  target_dir          "zabbix-#{node['zabbix']['server']['version']}-server"  
  install_dir         node['zabbix']['install_dir']
  configure_options   configure_options.join(" ")

  action :install_server
end

# Install Init script
template "/etc/init.d/zabbix_server" do
  source init_template
  owner "root"
  group "root"
  mode "755"
  notifies :restart, "service[zabbix_server]", :delayed
end

# install zabbix server conf
template "#{node['zabbix']['etc_dir']}/zabbix_server.conf" do
  source "zabbix_server.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables ({
    :dbhost     => node['zabbix']['database']['dbhost'],
    :dbname     => node['zabbix']['database']['dbname'],
    :dbuser     => node['zabbix']['database']['dbuser'],
    :dbpassword => node['zabbix']['database']['dbpassword'],
    :dbport     => node['zabbix']['database']['dbport']
  })
  notifies :restart, "service[zabbix_server]", :delayed
end

# Define zabbix_agentd service
service "zabbix_server" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [ :start, :enable ]
end
