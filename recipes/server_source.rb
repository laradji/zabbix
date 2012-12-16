# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::default"

if node['zabbix']['server']['install'] && node['zabbix']['server']['db_install_method'] == "mysql"
  include_recipe "mysql::client"
end

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
    include_recipe "yum::epel"
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

# --prefix is controlled by install_dir
node['zabbix']['agent']['configure_options'].delete_if do |option|
  option.match(/\s*--prefix(\s|=).+/)
end

# installation of zabbix bin
script "install_zabbix_server" do
  interpreter "bash"
  user "root"
  cwd node['zabbix']['src_dir']
  action :nothing
  notifies :restart, "service[zabbix_server]"
  code <<-EOH
  tar xvfz #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}-server.tar.gz
  (cd zabbix-#{node['zabbix']['server']['version']} && ./configure --enable-server --prefix=#{node['zabbix']['install_dir']} #{node['zabbix']['server']['configure_options'].join(" ")})
  (cd zabbix-#{node['zabbix']['server']['version']} && make install)
  EOH
end

# Download zabbix source code
remote_file "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}-server.tar.gz" do
  source "http://downloads.sourceforge.net/project/zabbix/#{node['zabbix']['server']['branch']}/#{node['zabbix']['server']['version']}/zabbix-#{node['zabbix']['server']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
  notifies :run, "script[install_zabbix_server]", :immediately
end

# Install Init script
template "/etc/init.d/zabbix_server" do
  source init_template
  owner "root"
  group "root"
  mode "755"
  notifies :restart, "service[zabbix_server]"
end

# install zabbix server conf
template "#{node['zabbix']['etc_dir']}/zabbix_server.conf" do
  source "zabbix_server.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[zabbix_server]"
end

# Define zabbix_agentd service
service "zabbix_server" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [ :start, :enable ]
end

case node['zabbix']['server']['db_install_method']
when "mysql"
  include_recipe "zabbix::mysql_setup"
when "rds_mysql"
  include_recipe "zabbix::rds_mysql_setup"
end
