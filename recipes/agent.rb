include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"

root_dirs = [
  node['zabbix']['agent']['include_dir']
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    unless node['platform_family'] == "windows"
      owner "root"
      group "root"
      mode "755"
    end
    recursive true
    notifies :restart, "service[zabbix_agentd]"
  end
end

# Install configuration
template "zabbix_agentd.conf" do
  path ::File.join( node['zabbix']['etc_dir'], "zabbix_agentd.conf")
  source "zabbix_agentd.conf.erb"
  unless node['platform_family'] == "windows"
    owner "root"
    group "root"
    mode "644"
  end
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
