# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: common
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

# Define root owned folders
root_dirs = [
  node['zabbix']['etc_dir'],
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

# Define zabbix owned folders
zabbix_dirs = [
  node['zabbix']['log_dir'],
  node['zabbix']['run_dir']
]

# Create zabbix folders
zabbix_dirs.each do |dir|
  directory dir do
    owner node['zabbix']['login']
    group node['zabbix']['group']
    mode "755"
    recursive true
    # Only execute this if zabbix can't write to it. This handles cases of
    # dir being world writable (like /tmp)
    # [ File.word_writable? doesn't appear until Ruby 1.9.x ]
    not_if "su #{node['zabbix']['login']} -c \"test -d #{dir} && test -w #{dir}\""
  end
end

unless node['zabbix']['agent']['source_url']
  node.default['zabbix']['agent']['source_url'] = Chef::Zabbix.default_download_url(node['zabbix']['agent']['branch'], node['zabbix']['agent']['version'])
end

unless node['zabbix']['server']['source_url']
  node.default['zabbix']['server']['source_url'] = Chef::Zabbix.default_download_url(node['zabbix']['server']['branch'], node['zabbix']['server']['version'])
end


