# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe 'zabbix::common'
include_recipe 'zabbix::server_common'

configure_options = node['zabbix']['server']['configure_options'].dup
configure_options = (configure_options || Array.new).delete_if do |option|
  option.match(/\s*--prefix(\s|=).+/)
end

case node['zabbix']['database']['install_method']
when 'mysql', 'rds_mysql'
  with_mysql = '--with-mysql'
  configure_options << with_mysql unless configure_options.include?(with_mysql)
when 'postgres'
  with_postgresql = '--with-postgresql'
  configure_options << with_postgresql unless configure_options.include?(with_postgresql)
when 'oracle'
  client_arch = node['kernel']['machine'] == 'x86_64' ? 'client64' : 'client'
  oracle_lib_path = "/usr/lib/oracle/#{node['oracle-instantclient']['version']}/#{client_arch}/lib"
  oracle_include_path = "/usr/include/oracle/#{node['oracle-instantclient']['version']}/#{client_arch}"
  with_oracle_lib = "--with-oracle-lib=#{oracle_lib_path}"
  with_oracle_include = "--with-oracle-include=#{oracle_include_path}"
  configure_options << '--with-oracle' unless configure_options.include?('--with-oracle')
  configure_options << with_oracle_lib unless configure_options.include?(with_oracle_lib)
  configure_options << with_oracle_include unless configure_options.include?(with_oracle_include)
end

if node['zabbix']['server']['java_gateway_enable'] == true
  configure_options << '--enable-java' unless configure_options.include?('--enable-java')
end

node.normal['zabbix']['server']['configure_options'] = configure_options

zabbix_source 'install_zabbix_server' do
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
  source_url node['zabbix']['server']['source_url']
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
  code_dir node['zabbix']['src_dir']
  target_dir "zabbix-#{node['zabbix']['server']['version']}"
  install_dir node['zabbix']['install_dir']
  configure_options configure_options.join(' ')

  action :install_server
end
