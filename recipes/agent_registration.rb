# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

chef_gem "zabbixapi" do
  action :install
  version "~> 0.5.8"
end

require 'zabbixapi'

unless Chef::Config[:solo]
  zabbix_server = search(:node, "recipes:zabbix\\:\\:server").first
elsif node['zabbix']['server']['ipaddress']
  zabbix_server = node['zabbix']['server']['ipaddress']
else
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  Chef::Log.warn("You don't set node['zabbix']['server']['ipaddress']. Recipe fail")
  return
end

if port_open?(zabbix_server['zabbix']['web']['fqdn'], 80)
  zbx = ZabbixApi.connect(
    :url => "http://#{zabbix_server['zabbix']['web']['fqdn']}/api_jsonrpc.php",
    :user => zabbix_server['zabbix']['web']['login'],
    :password => zabbix_server['zabbix']['web']['password']
  )

  groups_id = []
  node['zabbix']['agent']['groups'].each do |group|
    ruby_block "Create group #{group} on Zabbix server" do
      block do
        zbx.hostgroups.create(
          :host => group
        )
      end
      not_if { zbx.hostgroups.get_id(:name => group) }
    end
    groups_id += [ :groupid => zbx.hostgroups.get_id(:name => group) ]
  end

  ruby_block "Create or update host on Zabbix server" do
    block do
      zbx.hosts.create_or_update(
        :host => node['zabbix']['agent']['hostname'],
        :interfaces => [
          {
            :dns => node['zabbix']['agent']['hostname'],
            :useip => 0
          }
        ],
        :groups => groups_id
      )
    end
  end
end
