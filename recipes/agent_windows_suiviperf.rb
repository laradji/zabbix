include_recipe "windows"

windows_package "zabbix" do
  if node['kernel']['machine'] == "x86"
    source "http://www.suiviperf.com/zabbix/zabbix_agent-2.0.2_x86.msi"
  elsif  node['kernel']['machine'] == "x86_64"
    source "http://www.suiviperf.com/zabbix/zabbix_agent-2.0.2_x64.msi"
  end
  options "SERVER=#{node['zabbix']['agent']['servers'].join(',')} /qn"
  action :install
end
