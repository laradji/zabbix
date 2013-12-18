include_recipe "zabbix::_repository"

case node['zabbix']['database']['install_method']
when "mysql"
  server_package = "zabbix-server-mysql"
when "postgres"
  server_package = "zabbix-server-pgsql"
end

package server_package do
  action :install
end

include_recipe "zabbix::database"

directory node['zabbix']['server']['include_dir'] do
  action :create
  recursive true
  owner "zabbix"
end

template "#{node['zabbix']['etc_dir']}/zabbix_server.conf" do
  source "zabbix_server.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables ({
    :dbhost             => node['zabbix']['database']['dbhost'],
    :dbname             => node['zabbix']['database']['dbname'],
    :dbuser             => node['zabbix']['database']['dbuser'],
    :dbpassword         => node['zabbix']['database']['dbpassword'],
    :dbport             => node['zabbix']['database']['dbport'],
    :java_gateway       => node['zabbix']['server']['java_gateway'],
    :java_gateway_port  => node['zabbix']['server']['java_gateway_port'],
    :java_pollers       => node['zabbix']['server']['java_pollers']
  })
  notifies :restart, "service[zabbix-server]", :delayed
end

service "zabbix-server" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [ :start, :enable ]
end

