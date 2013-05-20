# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

unless Chef::Config[:solo]
  zabbix_server = search(:node, "recipes:zabbix\\:\\:server").first
else 
  if node['zabbix']['web']['fqdn']
    zabbix_server = node
  else
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    Chef::Log.warn("If you did not set node['zabbix']['web']['fqdn'], the recipe will fail")
    return
  end
end

connection_info = {
  :url => "http://#{zabbix_server['zabbix']['web']['fqdn']}/api_jsonrpc.php",
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

zabbix_host node['zabbix']['agent']['hostname'] do
  create_missing_groups true
  server_connection     connection_info
  parameters            ({
                        :host => node['hostname'],
                        :groupNames => node['zabbix']['agent']['groups'],
                        :interfaces => [{
                                       :type => 1,
                                       :main => 1,
                                       :useip => 1,
                                       :ip => node['ipaddress'],
                                       :dns => node['fqdn'],
                                       :port => "10050"
                                       },
                                       {
                                       :type => 2,
                                       :main => 1,
                                       :useip => 1,
                                       :ip => node['ipaddress'],
                                       :dns => node['fqdn'],
                                       :port => "161"
                                       }]
                        })
  action :nothing
end

ruby_block "shim" do
  block do
  end
  notifies :create_or_update, "zabbix_host[#{node['zabbix']['agent']['hostname']}]", :delayed
end
