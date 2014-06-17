action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    template_ids = Zabbix::API.find_template_ids(connection, new_resource.name)

    if template_ids.empty?
      group_ids = Zabbix::API.find_hostgroup_ids(connection, new_resource.group)

      if group_ids.empty?
        Chef::Application.fatal! "Couldn't find a Hostgroup called #{new_resource.group}"
      end

      create_template_request = {
        :method => 'template.create',
        :params => {
          :host => new_resource.name,
          :groups => group_ids.first
        }
      }
      connection.query(create_template_request)
    end
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
