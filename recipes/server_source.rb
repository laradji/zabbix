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

packages = []
case node['platform']
when 'ubuntu', 'debian'
  packages = %w(fping libcurl4-openssl-dev libiksemel-utils libiksemel-dev libiksemel3 libsnmp-dev snmp php-pear)
  case node['zabbix']['database']['install_method']
  when 'mysql', 'rds_mysql'
    packages.push('libmysql++-dev', 'libmysql++3', 'libcurl3', 'php5-mysql', 'php5-gd')
  when 'postgres'
    packages.push('libssh2-1-dev')
  # Oracle oci8 PECL package installed below
  when 'oracle'
    php_packages = %w(php-pear php-dev)
    packages.push(*php_packages)
  end
  init_template = 'zabbix_server.init.erb'
when 'redhat', 'centos', 'scientific', 'amazon', 'oracle'
  include_recipe 'yum-epel'

  curldev = (node['platform_version'].to_i < 6) ? 'curl-devel' : 'libcurl-devel'

  packages = %w(fping iksemel-devel iksemel-utils net-snmp-libs net-snmp-devel openssl-devel redhat-lsb php-pear)
  packages.push(curldev)

  case node['zabbix']['database']['install_method']
  when 'mysql', 'rds_mysql'
    php_packages =
    if node['platform_version'].to_i < 6
      %w(php53-mysql php53-gd php53-bcmath php53-mbstring php53-xml)
    else
      %w(php-mysql php-gd php-bcmath php-mbstring php-xml)
    end
    packages.push(*php_packages)
  when 'postgres'
    php_packages =
    if node['platform_version'].to_i < 6
      %w(php5-pgsql php5-gd php5-xml)
    else
      %w(php-pgsql php-gd php-bcmath php-mbstring php-xml)
    end
    packages.push(*php_packages)
  # Oracle oci8 PECL package installed below
  when 'oracle'
    php_packages = %w(php-pear php-devel)
    packages.push(*php_packages)
  end
  init_template = 'zabbix_server.init-rh.erb'
end

packages.each do |pck|
  package pck do
    action :install
  end
end

# Install the oci8 pecl - common to both Debian and RHEL families
php_pear 'oci8' do
  preferred_state 'stable'
  action :install
  only_if { node['zabbix']['database']['install_method'] == 'oracle' }
end

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
  include_recipe 'java' # install a JDK if not present
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

# Install Init script
template '/etc/init.d/zabbix_server' do
  source init_template
  owner 'root'
  group 'root'
  mode '755'
  notifies :restart, 'service[zabbix_server]', :delayed
end

# install zabbix server conf
template "#{node['zabbix']['etc_dir']}/zabbix_server.conf" do
  source 'zabbix_server.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    :dbhost             => node['zabbix']['database']['dbhost'],
    :dbname             => node['zabbix']['database']['dbname'],
    :dbuser             => node['zabbix']['database']['dbuser'],
    :dbpassword         => node['zabbix']['database']['dbpassword'],
    :dbport             => node['zabbix']['database']['dbport'],
    :java_gateway       => node['zabbix']['server']['java_gateway'],
    :java_gateway_port  => node['zabbix']['server']['java_gateway_port'],
    :java_pollers       => node['zabbix']['server']['java_pollers']
  )
  notifies :restart, 'service[zabbix_server]', :delayed
end

# Define zabbix_agentd service
service 'zabbix_server' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:start, :enable]
end

# Configure the Java Gateway
if node['zabbix']['server']['java_gateway_enable'] == true
  include_recipe 'zabbix::java_gateway'
end
