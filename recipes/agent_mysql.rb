#
# Author:: NAKAYAMA Masahiro <akitan@gmail.com>
# Cookbook Name:: zabbix
# Recipe:: agent_mysql
#
# Copyright 2013, NAKAYAMA Masahiro
#
# Apache 2.0
#

template "#{node['zabbix']['agent']['include_dir']}/userparameter_mysql.conf" do
  source 'userparameter_mysql.conf.erb'
  owner 'root'
  group 'zabbix'
  mode '0644'
  action :create
  notifies :restart, "service[zabbix_agentd]"
end

template node['zabbix']['agent']['mysql_conf'] do
  source 'my.cnf.erb'
  owner 'root'
  group 'zabbix'
  mode '0640'
  action :create
  notifies :restart, "service[zabbix_agentd]"
end

