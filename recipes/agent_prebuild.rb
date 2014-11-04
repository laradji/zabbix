# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_prebuild
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe 'zabbix::agent_common'

# Install prerequisite RPM
package 'redhat-lsb' if node['platform_family'] == 'rhel'

ark 'zabbix_agent' do
  name 'zabbix'
  url node['zabbix']['agent']['prebuild']['url']
  owner node['zabbix']['agent']['user']
  group node['zabbix']['agent']['group']
  action :put
  path '/opt'
  strip_components 0
  has_binaries ['bin/zabbix_sender', 'bin/zabbix_get', 'sbin/zabbix_agent', 'sbin/zabbix_agentd']
  notifies :restart, 'service[zabbix_agentd]'
  checksum node['zabbix']['agent']['checksum']
end
