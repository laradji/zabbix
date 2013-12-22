# Copyright 2013, Ian Delahorne <ian.delahorne@gmail.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

