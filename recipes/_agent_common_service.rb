# Manage Agent service
case node['zabbix']['agent']['init_style']
when "sysvinit"
  if node['zabbix']['agent']['install_method'] == 'package'
    svc_name = 'zabbix-agent'
  else
    svc_name = 'zabbix_agentd'
    template "/etc/init.d/zabbix_agentd" do
      source value_for_platform_family([ "rhel" ] => "zabbix_agentd.init-rh.erb", "default" => "zabbix_agentd.init.erb")
      owner "root"
      group "root"
      mode "754"
    end
  end
  # Define zabbix_agentd service
  service "zabbix-agentd" do
    service_name svc_name
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
when "windows"
  service "zabbix-agentd" do
    service_name "Zabbix Agent"
    provider Chef::Provider::Service::Windows
    supports :restart => true
    action :nothing
  end
end
