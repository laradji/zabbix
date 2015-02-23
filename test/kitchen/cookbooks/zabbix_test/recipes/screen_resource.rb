# Author:: Pal David Gergely (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix-test
# Recipe:: screen_resource
#
# Copyright 2015, Pal David Gergely
#
# Apache 2.0

# First a working Zabbix server is needed to have an API to test the resource
# against it, so intalling it with a database
node.normal['zabbix']['server']['install']      = true
node.normal['zabbix']['server']['version']      = '2.2.8'
node.normal['zabbix']['database']['dbpassword'] = 'foobar'
include_recipe 'mysql::server'
# Needed for the mysql gem install
package 'libmysqlclient-dev'
include_recipe 'zabbix::database'
include_recipe 'zabbix::server'
include_recipe 'zabbix::web'

# Now trigger an immediate restart on Apache to get the Zabbix API working
# before using it, TODO: not very nice, but needed
service 'apache2' do
  action :reload
end

# Also add the VM itself to Zabbix hosts, since monitored items are needed for
# the screen items to be able to test them
zabbix_host 'localhost' do
    parameters({
        groupNames: ['Linux servers'],
        templates: ['Template OS Linux'],
        interfaces: [Chef::Zabbix::API::HostInterface.new(type: Chef::Zabbix::API::HostInterfaceType.new(1), main: 1, useip: 1, ip: '127.0.0.1', port: 10050)]
    })
    server_connection({
        url: 'http://127.0.0.1/api_jsonrpc.php',
        user: 'Admin',
        password: 'zabbix'
    })
end

# Then create a simple test screen to validate that the screen resource is
# working
zabbix_screen 'test-screen' do
    hsize 2
    vsize 2
    screen_items [
        {
            resourcetype: 1,
            colspan: 1,
            rowspan: 1,
            elements: 25,
            height: 200,
            resourceid: {host: 'localhost', key_: 'system.cpu.load[percpu,avg1]'},
            width: 320,
            x: 0,
            y: 0
        },
        {
            resourcetype: 0,
            colspan: 0,
            rowspan: 0,
            elements: 25,
            height: 200,
            resourceid: {host: 'localhost', name: 'CPU load'},
            width: 320,
            x: 1,
            y: 1
        }
    ]
    server_connection({
        url: 'http://127.0.0.1/api_jsonrpc.php',
        user: 'Admin',
        password: 'zabbix'
    })
end
