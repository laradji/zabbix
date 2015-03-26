#
# Cookbook Name:: zabbix
# Recipe:: agent_package
#
# Copyright (C) 2014 Jorge Espada
#
# Apache 2.0
#

# in case you using a wrapper or already have a recipe to install custom repos
include_recipe node['zabbix']['agent_package_custom']['custom_repo_recipe'] if node['zabbix']['agent_package_custom']['custom_repo_recipe']

# Install prerequisite RPM
package 'redhat-lsb' if node['platform_family'] == 'rhel'

package 'zabbix-agent' do
  package_name node['zabbix']['agent_package_custom']['package_name']
  version node['zabbix']['agent_package_custom']['package_version']
  action node['zabbix']['agent_package_custom']['package_action']
  options node['zabbix']['agent_package_custom']['package_options']
end
