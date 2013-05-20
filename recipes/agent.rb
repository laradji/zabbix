include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"

# Install configuration
template "zabbix_agentd.conf" do
  path ::File.join( node['zabbix']['etc_dir'], "zabbix_agentd.conf")
  source "zabbix_agentd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[zabbix_agentd]"
end

case node['zabbix']['agent']['init_style']
when "sysvinit"
  template "/etc/init.d/zabbix_agentd" do
    source value_for_platform_family([ "rhel" ] => "zabbix_agentd.init-rh.erb", "default" => "zabbix_agentd.init.erb")
    owner "root"
    group "root"
    mode "754"
  end

  # Define zabbix_agentd service
  service "zabbix_agentd" do
    supports :status => true, :start => true, :stop => true, :restart => true
    action [ :enable, :start ]
  end
when "windows"
  service "zabbix_agentd" do
    service_name "Zabbix Agent"
    provider Chef::Provider::Service::Windows
    supports :restart => true
    action [ :enable, :start ]
  end
end

root_dirs = [
  node['zabbix']['agent']['include_dir']
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "755"
    recursive true
    notifies :restart, "service[zabbix_agentd]"
  end
end
