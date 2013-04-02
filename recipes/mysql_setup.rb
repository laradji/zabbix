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
node.set_unless['zabbix']['server']['dbpassword'] = secure_password

mysql_connection_info = {
  :host => node['zabbix']['server']['dbhost'], 
  :dbname => node['zabbix']['server']['dbname'],
  :root_password => node[:mysql][:server_root_password],
  :username => node['zabbix']['server']['dbuser'],
  :password => node['zabbix']['server']['dbpassword']
}

zabbix_mysql_setup "Server DB Setup" do
  mysql_connection_info mysql_connection_info
end
