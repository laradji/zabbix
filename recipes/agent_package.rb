# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_package
#
# Copyright 2011, Efactures
#
# Apache 2.0
#
node.default['zabbix']['agent']['service_name'] = 'zabbix-agent'

include_recipe 'zabbix::agent_common'
include_recipe 'zabbix::_package_common'

package 'zabbix-agent'
