include_recipe "windows"

windows_package "zabbix" do
  if node['kernel']['machine'] == "x86"
    source "http://www.suiviperf.com/zabbix/zabbix_agent-2.0.2_x86.msi"
  elsif  node['kernel']['machine'] == "x86_64"
    source "http://www.suiviperf.com/zabbix/zabbix_agent-2.0.2_x64.msi"
  end
  options "/qn"
  action :install
end

service "zabbix_agentd" do
  service_name "Zabbix Agent"
  provider Chef::Provider::Service::Windows
  supports :restart => true
  action [ :enable, :start ]
end

template "C:/Program Files/Zabbix Agent/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  notifies :restart, "service[zabbix_agentd]"
end
