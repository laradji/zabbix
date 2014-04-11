# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

if !Chef::Config[:solo]
  zabbix_server = search(:node, 'recipe:zabbix\\:\\:server').first
else
  if node['zabbix']['web']['fqdn']
    zabbix_server = node
  else
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
    Chef::Log.warn("If you did not set node['zabbix']['web']['fqdn'], the recipe will fail")
    return
  end
end

connection_info = {
  :url => "http://#{zabbix_server['zabbix']['web']['fqdn']}/api_jsonrpc.php",
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

interface_definitions = {
  :zabbix_agent => {
    :type => 1,
    :main => 1,
    :useip => 1,
    :ip => node['ipaddress'],
    :dns => node['fqdn'],
    :port => '10050'
  },
  :jmx => {
    :type => 4,
    :main => 1,
    :useip => 1,
    :ip => node['ipaddress'],
    :dns => node['fqdn'],
    :port => '10052'
  },
  :snmp => {
    :type => 2,
    :main => 1,
    :useip => 1,
    :ip => node['ipaddress'],
    :dns => node['fqdn'],
    :port => '161'
  }
}

interface_list = node['zabbix']['agent']['interfaces']

interface_data = []
interface_list.each do |interface|
  if interface_definitions.key?(interface.to_sym)
    interface_data.push(interface_definitions[interface.to_sym])
  else
    Chef::Log.warn "WARNING: Interface #{interface} is not defined in agent_registration.rb"
  end
end

zabbix_host node['zabbix']['agent']['hostname'] do
  create_missing_groups true
  server_connection connection_info
  parameters(
    :host => node['hostname'],
    :groupNames => node['zabbix']['agent']['groups'],
    :templates => node['zabbix']['agent']['templates'],
    :interfaces => interface_data
  )
  action :nothing
end

log 'Delay agent registration to wait for server to be started' do
  level :debug
  notifies :create_or_update, "zabbix_host[#{node['zabbix']['agent']['hostname']}]", :delayed
end
