# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: mysql_setup
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database::mysql"

# generate the passwords
# This is INSECURE because node.set persists the passwords to the chef
# server, making them visible to anybody with access
#
# Under chef_solo these must be set somehow because node.set doesn't persist
# between runs
node.set_unless[:mysql][:server_root_password] = secure_password
node.set_unless['zabbix']['database']['dbpassword'] = secure_password

zabbix_database node['zabbix']['database']['dbname'] do
  host                    node['zabbix']['database']['dbhost']
  username                node['zabbix']['database']['dbuser']
  password                node['zabbix']['database']['dbpassword']
  root_username           "root"
  root_password           node[:mysql][:server_root_password]
  allowed_user_hosts      "localhost"
  zabbix_source_dir       node['zabbix']['src_dir']
  zabbix_server_version   node['zabbix']['server']['version']
end
