# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_common
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

root_dirs = [
  node['zabbix']['external_dir'],
  node['zabbix']['server']['include_dir'],
  node['zabbix']['alert_dir']
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "755"
    recursive true
  end
end
