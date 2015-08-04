# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server_common
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

if node['zabbix']['login']
  # Create zabbix group
  group node['zabbix']['group'] do
    gid node['zabbix']['gid']
    action :nothing if node['zabbix']['gid'].nil?
  end

  # Create zabbix User
  user node['zabbix']['login'] do
    comment 'zabbix User'
    home node['zabbix']['install_dir']
    shell node['zabbix']['shell']
    uid node['zabbix']['uid']
    gid node['zabbix']['gid']
  end
end

root_dirs = [
  node['zabbix']['external_dir'],
  node['zabbix']['server']['include_dir'],
  node['zabbix']['alert_dir']
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end
end

packages = []
case node['platform']
when 'ubuntu', 'debian'
  packages = %w(fping libiksemel-utils libiksemel3 snmp php-pear)
  packages.push('libcurl4-openssl-dev', 'libiksemel-dev', 'libsnmp-dev')
  case node['zabbix']['database']['install_method']
  when 'mysql', 'rds_mysql'
    packages.push('libmysql++3', 'libcurl3', 'php5-mysql', 'php5-gd')
    packages.push('libmysql++-dev')

  when 'postgres'
    packages.push('libssh2-1-dev')

  # Oracle oci8 PECL package installed below
  when 'oracle'
    packages.push('php-pear')
    packages.push('php-dev')
  end
  init_template = 'zabbix_server.init.erb'

when 'redhat', 'centos', 'scientific', 'amazon', 'oracle'
  include_recipe 'yum-epel'

  curldev = (node['platform_version'].to_i < 6) ? 'curl-devel' : 'libcurl-devel'
  packages = %w(fping iksemel-utils net-snmp-libs redhat-lsb php-pear)
  packages.push(curldev, 'iksemel-devel', 'net-snmp-devel', 'openssl-devel')

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
    packages.push('php-pear')
    packages.push('php-devel')
  end
  init_template = 'zabbix_server.init-rh.erb'
end

packages.delete_if do |item|
  item.match(/-dev(el)?$/)
end if node['zabbix']['server']['install_method'] != 'source'

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

# Install Init script
template '/etc/init.d/zabbix_server' do
  source init_template
  owner 'root'
  group 'root'
  mode '755'
  notifies :restart, 'service[zabbix_server]', :delayed
end

# Define zabbix_server service
service 'zabbix_server' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:enable]
end

# Configure the Java Gateway
if node['zabbix']['server']['java_gateway_enable'] == true
  include_recipe 'zabbix::java_gateway'
end
