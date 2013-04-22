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

zabbixServer = search(:node, "recipes:zabbix\\:\\:server").first
if port_open?(zabbixServer['zabbix']['web']['fqdn'], 80)

  zbx = ZabbixApi.connect(
    :url => "http://#{zabbixServer['zabbix']['web']['fqdn']}/api_jsonrpc.php",
    :user => zabbixServer['zabbix']['web']['login'],
    :password => zabbixServer['zabbix']['web']['password']
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
