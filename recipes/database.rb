::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database::mysql"
include_recipe "mysql::client"

# Generates passwords if they aren't already set
# This is INSECURE because node.set persists the passwords to the chef
# server, making them visible to anybody with access
#
# Under chef_solo these must be set somehow because node.set doesn't persist
# between runs
node.set_unless['zabbix']['database']['dbpassword'] = secure_password
if node['zabbix']['database']['install_method'] == 'rds_mysql'
  root_username       = node['zabbix']['database']['rds_master_username']
  root_password       = node['zabbix']['database']['rds_master_password']
  allowed_user_hosts  = "%"
else
  node.set_unless[:mysql][:server_root_password] = secure_password
  root_username       = "root"
  root_password       = node[:mysql][:server_root_password]
  allowed_user_hosts  = "localhost"
end

zabbix_database node['zabbix']['database']['dbname'] do
  host                    node['zabbix']['database']['dbhost']
  username                node['zabbix']['database']['dbuser']
  password                node['zabbix']['database']['dbpassword']
  root_username           root_username
  root_password           root_password
  allowed_user_hosts      allowed_user_hosts
  server_branch           node['zabbix']['server']['branch']
  server_version          node['zabbix']['server']['version']
  source_dir              node['zabbix']['src_dir']
  install_dir             node['zabbix']['install_dir']

end
