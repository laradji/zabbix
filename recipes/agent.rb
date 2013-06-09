include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
include_recipe "zabbix::agent_common"

# Install configuration
template "zabbix_agentd.conf" do
  path node['zabbix']['agent']['config_file']
  source "zabbix_agentd.conf.erb"
  unless node['platform_family'] == "windows"
    owner "root"
    group "root"
    mode "644"
  end
  notifies :restart, "service[zabbix_agentd]"
end

ruby_block "start service" do
  block do
    true
  end
  Array(node['zabbix']['agent']['service_state']).each do |action|
    notifies action, "service[zabbix_agentd]"
  end
end
