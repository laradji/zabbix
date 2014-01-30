# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_common
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

if node['zabbix']['login']
  # Create zabbix group
  group node['zabbix']['group'] do
    gid node['zabbix']['gid']
    if node['zabbix']['gid'].nil?
      action :nothing
    else
      action :create
    end
  end

  # Create zabbix User
  user node['zabbix']['login'] do
    comment "zabbix User"
    home node['zabbix']['install_dir']
    shell node['zabbix']['shell']
    uid node['zabbix']['uid']
    gid node['zabbix']['gid']
  end
end

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

node.normal['zabbix']['web']['ip'] = (node["cloud"]) ? node["cloud"]["local_ipv4"] : node["ipaddress"]

# Create api scripts folder and files
remote_directory "/etc/zabbix/scripts/api" do
       source "scripts_api"
       files_owner "root"
       files_group "root"
       files_mode 00600
       owner "root"
       group "root"
       action :create
end
