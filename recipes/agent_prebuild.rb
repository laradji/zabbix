# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_prebuild
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

# Install Init script
template "/etc/init.d/zabbix_agentd" do
  source value_for_platform([ "centos", "redhat", "scientific" ] => {"default" => "zabbix_agentd.init-rh.erb"}, "default" => "zabbix_agentd.init.erb")
  owner "root"
  group "root"
  mode "754"
end

# Define zabbix_agentd service
service "zabbix_agentd" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [ :enable ]
end

# Install configuration
template "#{node.zabbix.etc_dir}/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[zabbix_agentd]"
  variables(
    :ztc =>  node['recipes'].include?('zabbix::agent_ztc')
  )
end

# Define arch for binaries
if node.kernel.machine == "x86_64"
  $zabbix_arch = "amd64"
elsif node.kernel.machine == "i686"
  $zabbix_arch = "i386"
end

# installation of zabbix bin
script "install_zabbix_agent" do
  interpreter "bash"
  user "root"
  cwd node.zabbix.install_dir
  action :nothing
  notifies :restart, "service[zabbix_agentd]"
  code <<-EOH
  tar xvfz #{node.zabbix.src_dir}/zabbix_agents_#{node.zabbix.agent.version}.linux2_6.#{$zabbix_arch}.tar.gz
  EOH
end
  
# Download and intall zabbix agent bins.
remote_file "#{node.zabbix.src_dir}/zabbix_agents_#{node.zabbix.agent.version}.linux2_6.#{$zabbix_arch}.tar.gz" do
  source "http://www.zabbix.com/downloads/#{node.zabbix.agent.version}/zabbix_agents_#{node.zabbix.agent.version}.linux2_6.#{$zabbix_arch}.tar.gz"
  mode "0644"
  action :create_if_missing
  notifies :run, "script[install_zabbix_agent]", :immediately
end



