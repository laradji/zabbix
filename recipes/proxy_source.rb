# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe 'zabbix::_server_common_build_deps'

Chef::Log.info "zabbix::proxy_source.rb : config opts are #{node['zabbix']['server']['configure_options']}"
zabbix_source 'install_zabbix_server' do
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
  source_url node['zabbix']['server']['source_url']
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
  code_dir node['zabbix']['src_dir']
  target_dir "zabbix-#{node['zabbix']['server']['version']}"
  install_dir node['zabbix']['install_dir']
  configure_options node['zabbix']['server']['configure_options'].join(' ')
  action :install_server
end

case node['platform']
when 'ubuntu', 'debian'
  init_template = 'zabbix_server.init.erb'
when 'redhat', 'centos', 'scientific', 'amazon', 'oracle'
  init_template = 'zabbix_server.init-rh.erb'
end

# Install Init script
template '/etc/init.d/zabbix_proxy' do
  source init_template
  owner 'root'
  group 'root'
  mode '755'
  notifies :restart, 'service[zabbix_proxy]', :delayed
end

# install zabbix server conf
template "#{node['zabbix']['etc_dir']}/zabbix_proxy.conf" do
  source 'zabbix_proxy.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    # For sqlite the nil DB values will not be rendered in the template
    :dbhost             => node['zabbix']['proxy']['database']['dbhost'],
    :dbname             => node['zabbix']['proxy']['database']['dbname'],
    :dbuser             => node['zabbix']['proxy']['database']['dbuser'],
    :dbpassword         => node['zabbix']['proxy']['database']['dbpassword'],
    :dbport             => node['zabbix']['proxy']['database']['dbport'],
    # Likewise for Java gateway - if not enabled then these won't be rendered
    :java_gateway       => node['zabbix']['server']['java_gateway'],
    :java_gateway_port  => node['zabbix']['server']['java_gateway_port'],
    :java_pollers       => node['zabbix']['server']['java_pollers']
  )
  notifies :restart, 'service[zabbix_proxy]', :delayed
end

# Define zabbix_proxy service
service 'zabbix_proxy' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:start, :enable]
end

# Configure the Java Gateway
if node['zabbix']['server']['java_gateway_enable'] == true
  include_recipe 'zabbix::java_gateway'
end
