include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
include_recipe 'zabbix::agent_common'

# Install configuration
template 'zabbix_agentd.conf' do
  path node['zabbix']['agent']['config_file']
  source 'zabbix_agentd.conf.erb'
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '644'
  end
  notifies :restart, 'service[zabbix_agentd]'
end

# Install optional additional agent config file containing UserParameter(s)
template 'user_params.conf' do
  path node['zabbix']['agent']['userparams_config_file']
  source 'user_params.conf.erb'
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '644'
  end
  notifies :restart, 'service[zabbix_agentd]'
  only_if { node['zabbix']['agent']['user_parameter'].length > 0 }
end

# Install custom scripts
node['zabbix']['agent']['user_script'].each do |script|
  cookbook_file File.join(node['zabbix']['agent']['scripts_dir'], script) do
    source "scripts/#{script}"
    unless node['platform_family'] == 'windows'
      owner 'root'
      group 'root'
      mode '755'
    end
    action :create_if_missing
  end
end

ruby_block 'start service' do
  block do
    true
  end
  Array(node['zabbix']['agent']['service_state']).each do |action|
    notifies action, 'service[zabbix_agentd]'
  end
end
