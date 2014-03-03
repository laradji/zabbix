# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix-test
# Recipe:: server_source
#
# Copyright 2011, Efactures
#
# Apache 2.0

node.normal['zabbix']['server']['install'] = true
include_recipe 'zabbix::server_source'
