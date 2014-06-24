# Author:: Fred Clausen (<ftclausen@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: _server_common_build_deps.rb
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
  when 'sqlite'
    # Only do this if the proxy is actually enabled
    # since sqlite is only an option with the proxy
    if node['zabbix']['proxy']['enabled']
      packages.push('sqlite3', 'libsqlite3-dev')
    else
      Chef::Application.fatal 'sqlite DB only applies to Zabbix proxies!'
    end
  end
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
  when 'sqlite'
    # Only do this if the proxy is actually enabled
    # since sqlite is only an option with the proxy
    if node['zabbix']['proxy']['enabled']
      packages.push('sqlite', 'sqlite-devel')
    else
      Chef::Application.fatal 'sqlite db only applies to zabbix proxies!'
    end
  end
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
when 'sqlite'
  # Only do this if the proxy is actually enabled
  # since sqlite is only an option with the proxy
  if node['zabbix']['proxy']['enabled']
    with_sqlite = '--with-sqlite3'
    configure_options << with_sqlite unless configure_options.include?(with_sqlite)
  else
    Chef::Application.fatal 'sqlite db only applies to zabbix proxies!'
  end
end

if node['zabbix']['server']['java_gateway_enable'] == true
  include_recipe 'java' # install a JDK if not present
  configure_options << '--enable-java' unless configure_options.include?('--enable-java')
end

if node['zabbix']['proxy']['enabled'] == true
  configure_options << '--enable-proxy' unless configure_options.include?('--enable-proxy')
end

node.normal['zabbix']['server']['configure_options'] = configure_options
node.save
