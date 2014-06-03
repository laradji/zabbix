include_recipe 'zabbix::common'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'database::mysql'
include_recipe 'mysql::client'

# Generates passwords if they aren't already set
# This is INSECURE because node.normal persists the passwords to the chef
# server, making them visible to anybody with access
#
# Under chef_solo these must be set somehow because node.normal doesn't persist
# between runs

unless node['zabbix']['database']['dbpassword']
  node.normal['zabbix']['database']['dbpassword'] = secure_password
end

case node['zabbix']['database']['install_method']
when 'rds_mysql'
  root_username       = node['zabbix']['database']['rds_master_username']
  root_password       = node['zabbix']['database']['rds_master_password']
  allowed_user_hosts  = '%'
  provider = Chef::Provider::ZabbixDatabaseMySql
when 'mysql'
  unless node['mysql']['server_root_password']
    node.normal['mysql']['server_root_password'] = secure_password
  end
  root_username       = 'root'
  root_password       = node['mysql']['server_root_password']
  allowed_user_hosts  = node['zabbix']['database']['allowed_user_hosts']
  provider = Chef::Provider::ZabbixDatabaseMySql
when 'postgres'
  unless node['postgresql']['password']['postgres']
    node.normal['postgresql']['password']['postgres'] = secure_password
  end
  root_username       = 'postgres'
  root_password       = node['postgresql']['password']['postgres']
  provider = Chef::Provider::ZabbixDatabasePostgres
when 'oracle'
  # No oracle database installation or configuration currently done
  # This recipe expects a fully configured Oracle DB with a Zabbix
  # user + schema. The instant client is just for compiling php-oci8
  # and Zabbix itself
  include_recipe 'oracle-instantclient'
  include_recipe 'oracle-instantclient::sdk'
  # Not used yet but needs to be set
  root_username       = 'sysdba'
  root_password       = 'not_applicable'
  provider = Chef::Provider::ZabbixDatabaseOracle
end

zabbix_database node['zabbix']['database']['dbname'] do
  provider provider
  host node['zabbix']['database']['dbhost']
  port node['zabbix']['database']['dbport'].to_i
  username node['zabbix']['database']['dbuser']
  password node['zabbix']['database']['dbpassword']
  root_username root_username
  root_password root_password
  allowed_user_hosts allowed_user_hosts
  source_url node['zabbix']['server']['source_url']
  server_version node['zabbix']['server']['version']
  source_dir node['zabbix']['src_dir']
  install_dir node['zabbix']['install_dir']
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
end
