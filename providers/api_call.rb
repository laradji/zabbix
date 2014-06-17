action :call do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    connection.query(
      :method => new_resource.method,
      :params => new_resource.parameters
    )
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end

def validate_parameters(parameters)
  Chef::Log.error("#{parameter} isn't an Hash") unless parameters.is_a?(Hash)
end
