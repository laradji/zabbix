# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

chef_gem "zabbixapi"

require 'zabbixapi'

zabbixServer = search(:node, 'chef_environment:#{node.chef_environment} AND recipes:zabbix\:\:server').first
zbx = Zabbix::ZabbixApi.new("http://#{zabbixServer['zabbix']['web']['fqdn']}/api_jsonrpc.php",zabbixServer['zabbix']['web']['login'],zabbixServer['zabbix']['web']['password'])

ruby_block "register agent" do
  block do
    zbx.add_host({
      :host => node['zabbix']['agent']['hostname']
    })
  end
  not_if { zbx.get_host_id(node['zabbix']['agent']['hostname']) }
end
