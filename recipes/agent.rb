
case node['zabbix']['agent']['init_style']
when "sysvinit"
  template "/etc/init.d/zabbix_agentd" do
    source value_for_platform_family([ "rhel" ] => {"default" => "zabbix_agentd.init-rh.erb"}, "default" => "zabbix_agentd.init.erb")
    owner "root"
    group "root"
    mode "754"
  end

  # Define zabbix_agentd service
  service "zabbix_agentd" do
    supports :status => true, :start => true, :stop => true, :restart => true
    action [ :enable ]
  end
end

# Install configuration
template "zabbix_agentd.conf" do
  path File.join( node['zabbix']['etc_dir'], "zabbix_agentd.conf")
  source "zabbix_agentd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[zabbix_agentd]"
end

include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
