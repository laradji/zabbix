# Author:: Friedrich Clausen (<ftclausen@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: java_gateway
#
# Apache 2.0
#

include_recipe 'java'

template '/etc/zabbix/zabbix_java_gateway.conf' do
  source 'zabbix-java-gateway/zabbix_java_gateway.conf.erb'
  variables(
    :java_gateway_listen_ip => node['zabbix']['server']['java_gateway_listen_ip'],
    :java_gateway_listen_port => node['zabbix']['server']['java_gateway_listen_port'],
    :java_gateway_pollers => node['zabbix']['server']['java_gateway_pollers']
  )
  owner 'zabbix'
  group 'zabbix'
  mode '0644'
  notifies :restart, 'service[zabbix-java-gateway]'
end

cookbook_file '/etc/zabbix/zabbix_java_gateway.logback.xml' do
  source 'zabbix-java-gateway/zabbix_java_gateway.logback.xml'
  owner 'zabbix'
  group 'zabbix'
  mode '0644'
  notifies :restart, 'service[zabbix-java-gateway]'
end

case node['platform_family']
when 'rhel', 'fedora', 'suse'
  cookbook_file '/etc/init.d/zabbix-java-gateway' do
    source 'zabbix-java-gateway/init.rhel'
    owner 'root'
    group 'root'
    mode '0755'
  end
when 'debian'
  cookbook_file '/etc/init.d/zabbix-java-gateway' do
    source 'zabbix-java-gateway/init.debian'
    owner 'root'
    group 'root'
    mode '0755'
  end
end

service 'zabbix-java-gateway' do
  service_name 'zabbix-java-gateway'
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

# Dummy file saying look at /etc/zabbix/zabbix_java_gateway.conf
cookbook_file '/opt/zabbix/sbin/zabbix_java/settings.sh' do
  source 'zabbix-java-gateway/settings.sh'
  owner 'zabbix'
  group 'zabbix'
  mode '0644'
end
