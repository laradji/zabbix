# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: mysql_setup
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database::mysql"


# generate the password
node.set_unless['zabbix']['server']['dbpassword'] = secure_password

mysql_connection_info = {:host => node['zabbix']['server']['dbhost'], :username => "root", :password => node['mysql']['server_root_password']}

# create zabbix database
mysql_database node['zabbix']['server']['dbname'] do
  connection mysql_connection_info
  action :create
  notifies :run, "execute[zabbix_populate_schema]", :immediately
  notifies :run, "execute[zabbix_populate_image]", :immediately
  notifies :run, "execute[zabbix_populate_data]", :immediately
  notifies :create, "template[#{node['zabbix']['etc_dir']}/zabbix_server.conf]", :immediately
  notifies :create, "mysql_database_user[#{node['zabbix']['server']['dbuser']}]", :immediately
  notifies :grant, "mysql_database_user[#{node['zabbix']['server']['dbuser']}]", :immediately
  notifies :restart, "service[zabbix_server]", :immediately
end

# populate database
if node['zabbix']['server']['version'].to_f < 2.0
  Chef::Log.info "Version 1.x branch of zabbix in use"
  execute "zabbix_populate_schema" do
    command "/usr/bin/mysql -u root #{node['zabbix']['server']['dbname']} -p#{node['mysql']['server_root_password']} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/create/schema/mysql.sql"
    action :nothing
  end
  execute "zabbix_populate_data" do
    command "/usr/bin/mysql -u root #{node['zabbix']['server']['dbname']} -p#{node['mysql']['server_root_password']} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/create/data/data.sql"
    action :nothing
  end
  execute "zabbix_populate_image" do
  command "/usr/bin/mysql -u root #{node['zabbix']['server']['dbname']} -p#{node['mysql']['server_root_password']} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/create/data/images_mysql.sql"
   action :nothing
  end
else
  Chef::Log.info "Version 2.x branch of zabbix in use"
  execute "zabbix_populate_schema" do
    command "/usr/bin/mysql -u root #{node['zabbix']['server']['dbname']} -p#{node['mysql']['server_root_password']} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/database/mysql/schema.sql"
    action :nothing
  end
  execute "zabbix_populate_image" do
    command "/usr/bin/mysql -u root #{node['zabbix']['server']['dbname']} -p#{node['mysql']['server_root_password']} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/database/mysql/images.sql"
    action :nothing
  end
  execute "zabbix_populate_data" do
    command "/usr/bin/mysql -u root #{node['zabbix']['server']['dbname']} -p#{node['mysql']['server_root_password']} < #{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/database/mysql/data.sql"
    action :nothing
  end
end

# create and grant zabbix user
mysql_database_user node['zabbix']['server']['dbuser'] do
  connection mysql_connection_info
  password node['zabbix']['server']['dbpassword']
  database_name node['zabbix']['server']['dbname']
  host 'localhost'
  privileges [:select,:update,:insert,:create,:drop,:delete]
  action :nothing
end
