def whyrun_supported?
  true
end

action :add do
  Chef::Log.info "Adding /etc/zabbix/zabbix_agentd.conf.d/#{new_resource.param_key}.conf"

  service_name = node['zabbix']['agent']['service_name']
  include_dir = node['zabbix']['agent']['include_dir']

  # In some cases we want the keyname to be different from the filename of the config file
  # By default param_key is used for both, but if keyname is provided we use that for the actual
  # UserParameter key
  keyname = new_resource.param_key
  keyname = new_resource.keyname if new_resource.keyname
  file "#{include_dir}/#{new_resource.param_key}.conf" do
    content "# Configured by chef, do not edit\nUserParameter=#{keyname},#{new_resource.command}\n"
    owner node['zabbix']['user']
    group node['zabbix']['group']
    mode 0640
    notifies :restart, "service[#{service_name}]"
  end
  new_resource.updated_by_last_action(true)
end

action :remove do
  service_name = node['zabbix']['agent']['service_name']
  include_dir = node['zabbix']['agent']['include_dir']
  if ::File.exist?("#{include_dir}/#{new_resource.param_key}.conf")
    Chef::Log.info "Removing #{include_dir}/#{new_resource.param_key}.conf"
    file "#{include_dir}/#{new_resource.param_key}.conf" do
      action :delete
      notifies :restart, "service[#{service_name}]"
    end
    new_resource.updated_by_last_action(true)
  end
end
