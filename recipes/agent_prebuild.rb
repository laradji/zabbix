# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_prebuild
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::common"
include_recipe "zabbix::agent_common"

# Install prerequisite RPM
if node['platform_family'] == "rhel"
  package "redhat-lsb"
end

# Define arch for binaries
if node['kernel']['machine'] == "x86_64"
  $zabbix_arch = "amd64"
elsif node['kernel']['machine'] == "i686"
  $zabbix_arch = "i386"
end

ark "zabbix_agent" do
  name "zabbix"
  url "http://www.zabbix.com/downloads/#{node['zabbix']['agent']['version']}/zabbix_agents_#{node['zabbix']['agent']['version']}.linux2_6.#{$zabbix_arch}.tar.gz"
  owner node['zabbix']['login']
  group node['zabbix']['group']
  action :put
  path  "/opt"
  strip_leading_dir false
  has_binaries [ 'bin/zabbix_sender', 'bin/zabbix_get' ]
  notifies :restart, "service[zabbix_agentd]"
end
