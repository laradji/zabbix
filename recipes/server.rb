# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

if node['zabbix']['proxy']['enabled']
  include_recipe "zabbix::proxy_#{node['zabbix']['server']['install_method']}"
else
  include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"
end
