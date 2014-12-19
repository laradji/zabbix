# Manage Agent service
if platform_family?('windows')
  service 'zabbix_agentd' do
    service_name 'Zabbix Agent'
    provider Chef::Provider::Service::Windows
    supports :restart => true
    action :nothing
  end
elsif node['init_package'] == 'systemd'
  template '/lib/systemd/system/zabbix-agent.service' do
    source 'zabbix-agent.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  # RHEL package names it "zabbix-agent"
  service 'zabbix_agentd' do
    service_name 'zabbix-agent'
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
else
  package 'redhat-lsb' if platform_family?('rhel')

  template '/etc/init.d/zabbix_agentd' do
    source value_for_platform_family(['rhel'] => 'zabbix_agentd.init-rh.erb', 'default' => 'zabbix_agentd.init.erb')
    owner 'root'
    group 'root'
    mode '754'
  end

  # Define zabbix_agentd service
  service 'zabbix_agentd' do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
end
