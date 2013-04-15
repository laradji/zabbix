# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::common"

case node['platform']
when "ubuntu","debian"
  # install some dependencies
  %w{ fping libcurl3 libiksemel-dev libiksemel3 libsnmp-dev libiksemel-utils libcurl4-openssl-dev }.each do |pck|
    package pck do
      action :install
    end
  end
  init_template = 'zabbix_agentd.init.erb'
  
when "redhat","centos","scientific","amazon"
    %w{ fping curl-devel iksemel-devel iksemel-utils net-snmp-libs net-snmp-devel openssl-devel redhat-lsb }.each do |pck|
      package pck do
        action :install
      end
    end
  init_template = 'zabbix_agentd.init-rh.erb'
end

# Install configuration
template "#{node['zabbix']['etc_dir']}/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[zabbix_agentd]"
end

# Install Init script
template "/etc/init.d/zabbix_agentd" do
  source init_template
  owner "root"
  group "root"
  mode "754"
end

# Define zabbix_agentd service
service "zabbix_agentd" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [ :enable ]
end

# --prefix is controlled by install_dir
configure_options = (node['zabbix']['agent']['configure_options'] || Array.new).delete_if do |option|
  option.match(/\s*--prefix(\s|=).+/)
end
node.set['zabbix']['agent']['configure_options'] = configure_options

zabbix_source "install_zabbix_agent" do
  branch              node['zabbix']['agent']['branch']
  version             node['zabbix']['agent']['version']
  code_dir            node['zabbix']['src_dir']
  target_dir          "zabbix-#{node['zabbix']['agent']['version']}-agent"  
  install_dir         node['zabbix']['install_dir']
  configure_options   configure_options.join(" ")

  action :install_agent
end
