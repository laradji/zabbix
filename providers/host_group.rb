def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info("Create: Host Group '#{new_resource.group}' already exists")
  else
    converge_by("Creating Host Group '#{new_resource.group}'") do
      create_group(new_resource.group)
    end
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'

  @current_resource = Chef::Resource::ZabbixHostGroup.new(@new_resource.group)
  @current_resource.server_connection(@new_resource.server_connection)
  @current_resource.exists = group_exists?(@current_resource.group)
end

def group_exists?(group)
  id = Chef::Zabbix.with_connection(@current_resource.server_connection) do |connection|
    connection.hostgroups.get_id(:name => group)
  end
  !(id.nil?)
end

def create_group(group)
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    connection.hostgroups.create(:name => group)
  end
end
