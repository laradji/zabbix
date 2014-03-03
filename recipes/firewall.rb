# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: firewall
#
# Copyright 2011, Efactures
#
# Apache 2.0
#
# This is the firewall part of zabbix installation.
#

include_recipe 'ufw'
# enable platform default firewall
firewall 'ufw' do
  action :enable
end

if node['zabbix']['server']['install'] == true
  # Search for some client
  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  else
    zabbix_clients = search(:node , 'recipes:zabbix')

    zabbix_clients.each do |client|
      # Accept connection from zabbix_server on agent
      firewall_rule "zabbix_client_#{client[:fqdn]}" do
        port 10_051
        source client[:ipaddress]
        action :allow
      end
    end if zabbix_clients

    # Localhost too
    firewall_rule 'zabbix_client_127.0.0.1}' do
      port 10_051
      source '127.0.0.1'
      action :allow
    end
  end
end

# Search for some client
if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  zabbix_servers = search(:node , 'recipes:zabbix\:\:server')
  zabbix_servers.each do |server|

    # Accept connection from zabbix_agent on server
    firewall_rule "zabbix_server_#{server[:fqdn]}" do
      port 10_050
      source server[:ipaddress]
      action :allow
    end
  end if zabbix_servers
end

# enable platform default firewall
firewall 'ufw' do
  action :enable
end
