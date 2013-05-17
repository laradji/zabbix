# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_prebuild
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::common"

# Install prerequisite RPM
if node['platform_family'] == "rhel"
  package "redhat-lsb"
end

ark "zabbix_agent" do
  name "zabbix"
  url node['zabbix']['agent']['prebuild']['url']
  owner node['zabbix']['login']
  group node['zabbix']['group']
  action :put
  path  "/opt"
  strip_leading_dir false
  has_binaries [ 'bin/zabbix_sender', 'bin/zabbix_get' ]
  notifies :restart, "service[zabbix_agentd]"
end
