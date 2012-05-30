# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: mysql_rds_setup
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database"
include_recipe "mysql::client"

#gem_package "mysql" do
#  action :install
#  ignore_failure true
#end

# generate the password
node.set_unless['zabbix']['server']['dbpassword'] = secure_password

mysql_connection_info = {:host => node['zabbix']['server']['rds_host'], :username => node['zabbix']['server']['rds_master_user'], :password => node['zabbix']['server']['rds_master_password']}

# create zabbix database
mysql_database "#{node.zabbix.server.dbname}" do
  connection mysql_connection_info
  action :create
  notifies :run, "execute[zabbix_populate_schema]", :immediately
  notifies :run, "execute[zabbix_populate_image]", :immediately
  notifies :run, "execute[zabbix_populate_data]", :immediately
  notifies :create, "template[#{node.zabbix.etc_dir}/zabbix_server.conf]", :immediately
  notifies :create, "mysql_database_user[#{node.zabbix.server.dbuser}]", :immediately
  notifies :grant, "mysql_database_user[#{node.zabbix.server.dbuser}]", :immediately
  notifies :restart, "service[zabbix_server]", :immediately
end

# populate database
if node.zabbix.server.version.to_f < 2.0
  Chef::Log.info "Version 1.x branch of zabbix in use"
  execute "zabbix_populate_schema" do
    command "/usr/bin/mysql -u #{node.zabbix.server.rds_master_user} -p#{node.zabbix.server.rds_master_password} -h #{node.zabbix.server.rds_host} #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/create/schema/mysql.sql"
    action :nothing
  end
  execute "zabbix_populate_data" do
    command "/usr/bin/mysql -u #{node.zabbix.server.rds_master_user} -p#{node.zabbix.server.rds_master_password} -h #{node.zabbix.server.rds_host} #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/create/data/data.sql"
    action :nothing
  end
  execute "zabbix_populate_image" do
  command "/usr/bin/mysql -u #{node.zabbix.server.rds_master_user} -p#{node.zabbix.server.rds_master_password} -h #{node.zabbix.server.rds_host} #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/create/data/images_mysql.sql"
   action :nothing
  end
else
  Chef::Log.info "Version 2.x branch of zabbix in use"
  execute "zabbix_populate_schema" do
    command "/usr/bin/mysql -u #{node.zabbix.server.rds_master_user} -p#{node.zabbix.server.rds_master_password} -h #{node.zabbix.server.rds_host} #{node.zabbix.server.dbname} < /opt/zabbix-#{node.zabbix.server.version}/database/mysql/schema.sql"
    action :nothing
  end
  execute "zabbix_populate_image" do
    command "/usr/bin/mysql -u #{node.zabbix.server.rds_master_user} -p#{node.zabbix.server.rds_master_password} -h #{node.zabbix.server.rds_host} #{node.zabbix.server.dbname} < /opt/zabbix-#{node.zabbix.server.version}/database/mysql/images.sql"
    action :nothing
  end
  execute "zabbix_populate_data" do
    command "/usr/bin/mysql -u #{node.zabbix.server.rds_master_user} -p#{node.zabbix.server.rds_master_password} -h #{node.zabbix.server.rds_host} #{node.zabbix.server.dbname} < /opt/zabbix-#{node.zabbix.server.version}/database/mysql/data.sql"
    action :nothing
  end
end

# create and grant zabbix user
mysql_database_user "#{node.zabbix.server.rds_master_user}" do
  connection mysql_connection_info
  password "#{node.zabbix.server.rds_master_password}"
  database_name "#{node.zabbix.server.dbname}"
  host "#{node.zabbix.server.rds_host}"
  privileges [:select,:update,:insert,:create,:drop,:delete]
  action :nothing
end


# create and grant zabbix user
mysql_database_user "#{node.zabbix.server.dbuser}" do
  connection mysql_connection_info
  password "#{node.zabbix.server.dbpassword}"
  database_name "#{node.zabbix.server.dbname}"
  host "#{node.zabbix.server.rds_host}"
  privileges [:select,:update,:insert,:create,:drop,:delete]
  action :nothing
end
