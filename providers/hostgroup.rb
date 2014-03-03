action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    hostgroup_id = connection.query(
      :method => 'hostgroup.get',
      :params => {
        :filter => {
          :name => new_resource.parameters[:name]
        }
      }
    )
    if hostgroup_id.size == 0
      connection.query(
        :method => 'hostgroup.create',
        :params => new_resource.parameters
      )
    end
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
