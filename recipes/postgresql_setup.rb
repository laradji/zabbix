# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: postgresql_setup
#
# Apache 2.0
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database"

# generate the password
node.set_unless['zabbix']['server']['dbpassword'] = secure_password

# port, user and password set by default
# TODO manage other host
# TODO manage attributes in a different way
postgresql_connection_info = {
                              :host => node['zabbix']['server']['dbhost'],
#                              :port => node['zabbix']['server']['dbport']
                             }

# create and grant zabbix user
postgresql_database_user "#{node.zabbix.server.dbuser}" do
  connection postgresql_connection_info
  password "#{node.zabbix.server.dbpassword}"
  database_name "#{node.zabbix.server.dbname}"
# already default to ":all"
#  privileges ["ALL"] default
  action :create
end

# create zabbix database
postgresql_database "#{node.zabbix.server.dbname}" do
  connection postgresql_connection_info
  owner node.zabbix.server.dbuser
  action :create
  notifies :run, "execute[zabbix_populate_schema]", :immediately
  notifies :run, "execute[zabbix_populate_image]", :immediately
  notifies :run, "execute[zabbix_populate_data]", :immediately
  notifies :create, "template[#{node.zabbix.etc_dir}/zabbix_server.conf]", :immediately
  notifies :grant, "postgresql_database_user[#{node.zabbix.server.dbuser}]", :immediately
  notifies :restart, "service[zabbix_server]", :immediately
end

# populate database
if node.zabbix.server.version.to_f < 2.0
  Chef::Log.info "Version 1.x branch of zabbix in use"
  execute "zabbix_populate_schema" do
    command "psql #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/create/schema/postgresql.sql"
    user node.zabbix.server.dbuser
    action :nothing
  end
  execute "zabbix_populate_data" do
    command "psql #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/create/data/data.sql"
    user node.zabbix.server.dbuser
    action :nothing
  end
  execute "zabbix_populate_image" do
    command "psql #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/create/data/images_pgsql.sql"
    user node.zabbix.server.dbuser
    action :nothing
  end
else
  Chef::Log.info "Version 2.x branch of zabbix in use"
  execute "zabbix_populate_schema" do
    command "psql #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/database/postgresql/schema.sql"
    user node.zabbix.server.dbuser
    action :nothing
  end
  execute "zabbix_populate_image" do
    command "psql #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/database/postgresql/images.sql"
    user node.zabbix.server.dbuser
    action :nothing
  end
  execute "zabbix_populate_data" do
    command "psql #{node.zabbix.server.dbname} < #{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/database/postgresql/data.sql"
    user node.zabbix.server.dbuser
    action :nothing
  end
end
