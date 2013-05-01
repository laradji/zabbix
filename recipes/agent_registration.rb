# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

if Chef::Config[:solo] && node['zabbix']['server']['ipaddress'].to_s.empty?
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  Chef::Log.warn("You don't set node['zabbix']['server']['ipaddress']. Recipe fail")
  return
else
  zabbix_server = node ||
    search(:node, "recipes:zabbix\\:\\:server").first 
end

connection_info = {
  :url      => "http://#{zabbix_server['zabbix']['web']['fqdn']}/api_jsonrpc.php",
  :user     => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

zabbix_host node['zabbix']['agent']['hostname'] do
  groups                node['zabbix']['agent']['groups']
  force_group_creation  true
  server_connection     connection_info
end
