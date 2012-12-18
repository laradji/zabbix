# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

if node['zabbix']['server']['install']
  include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"
  if node['zabbix']['agent']['install']
    node.set['zabbix']['agent']['servers'].unshift "localhost"
  end
end

if node['zabbix']['web']['install']
  include_recipe "zabbix::web"
end
