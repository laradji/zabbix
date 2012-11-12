# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_source
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

case node['platform']
when "ubuntu","debian"
  # install some dependencies
  %w{ fping libcurl3 libiksemel-dev libiksemel3 libsnmp-dev libiksemel-utils libcurl4-openssl-dev }.each do |pck|
    package pck do
      action :install
    end
  end
  init_template = 'zabbix_agentd.init.erb'
  
when "redhat","centos","scientific","amazon"
    include_recipe "yum::epel"
    %w{ fping curl-devel iksemel-devel iksemel-utils net-snmp-libs net-snmp-devel openssl-devel redhat-lsb }.each do |pck|
      package pck do
        action :install
      end
    end
  init_template = 'zabbix_agentd.init-rh.erb'
end

# Install configuration
template "#{node['zabbix']['etc_dir']}/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[zabbix_agentd]"
end

# Install Init script
template "/etc/init.d/zabbix_agentd" do
  source init_template
  owner "root"
  group "root"
  mode "754"
end

# Define zabbix_agentd service
service "zabbix_agentd" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [ :enable ]
end

# --prefix is controlled by install_dir
node['zabbix']['agent']['configure_options'].delete_if do |option|
  option.match(/\s*--prefix(\s|=).+/)
end

# installation of zabbix bin
script "install_zabbix_agent" do
  interpreter "bash"
  user "root"
  cwd node['zabbix']['src_dir']
  action :nothing
  notifies :restart, "service[zabbix_agentd]"
  code <<-EOH
  rm -rf /tmp/zabbix-#{node['zabbix']['agent']['version']}
  tar xvfz zabbix-#{node['zabbix']['agent']['version']}-agent.tar.gz -C /tmp
  mv /tmp/zabbix-#{node['zabbix']['agent']['version']} zabbix-#{node['zabbix']['agent']['version']}-agent
  (cd zabbix-#{node['zabbix']['agent']['version']}-agent && ./configure --enable-agent --prefix=#{node['zabbix']['install_dir']} #{node['zabbix']['agent']['configure_options'].join(" ")})
  (cd zabbix-#{node['zabbix']['agent']['version']}-agent && make install)
  EOH
end

# Download zabbix source code
remote_file "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['agent']['version']}-agent.tar.gz" do
  source "http://downloads.sourceforge.net/project/zabbix/#{node['zabbix']['agent']['branch']}/#{node['zabbix']['agent']['version']}/zabbix-#{node['zabbix']['agent']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
  notifies :run, "script[install_zabbix_agent]", :immediately
end
