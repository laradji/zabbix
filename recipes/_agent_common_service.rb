# Manage Agent service
case node['zabbix']['agent']['init_style']
when 'sysvinit'
  template '/etc/init.d/zabbix_agentd' do
    source value_for_platform_family(['rhel'] => 'zabbix_agentd.init-rh.erb', 'default' => 'zabbix_agentd.init.erb')
    owner 'root'
    group 'root'
    mode '754'
    # use package init script if installed form package
    not_if { node['zabbix']['agent']['install_method'] == 'package' }
  end

  # Define zabbix_agentd service
  service node['zabbix']['agent']['servicename'] do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
when 'windows'
  service 'zabbix_agentd' do
    service_name 'Zabbix Agent'
    provider Chef::Provider::Service::Windows
    supports :restart => true
    action :nothing
  end
end
