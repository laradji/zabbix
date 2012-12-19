# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

# Create zabbix group
group node['zabbix']['server']['group'] do
  gid node['zabbix']['server']['gid']
  if node['zabbix']['server']['gid'].nil? 
    action :nothing
  else
    action :create
  end
end

# Create zabbix User
user node['zabbix']['server']['login'] do
  comment "Zabbix Server User"
  home node['zabbix']['server']['install_dir']
  shell node['zabbix']['server']['shell']
  uid node['zabbix']['server']['uid']
  gid node['zabbix']['server']['gid']
  system true
end

# Define zabbix server owned folders
zabbix_dirs = [
  node['zabbix']['server']['log_dir'],
  node['zabbix']['server']['run_dir']
]

# Create zabbix folders
zabbix_dirs.each do |dir|
  directory dir do
    owner node['zabbix']['server']['login']
    group node['zabbix']['server']['group']
    mode "750"
    recursive true
    # Only execute this if zabbix server can't write to it. This handles cases of
    # dir being world writable (like /tmp)
    # [ File.word_writable? doesn't appear until Ruby 1.9.x ]
    not_if "su #{node['zabbix']['server']['login']} -c \"test -d #{dir} && test -w #{dir}\""
  end
end

if node['zabbix']['server']['install']
  include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"
  if node['zabbix']['agent']['install']
    node.set['zabbix']['agent']['servers'].unshift "localhost"
  end
end

if node['zabbix']['web']['install']
  include_recipe "zabbix::web"
end
