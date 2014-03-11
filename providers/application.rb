action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    # Convert the "hostname" (a template name) into a hostid

    template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
    if template_ids.empty?
      Chef::Application.fatal! "Could not find a template named #{new_resource.template}"
    end

    application_ids = Zabbix::API.find_application_ids(connection, new_resource.name, template_ids.first)

    if application_ids.empty?
      request = {
        :method => 'application.create',
        :params => {
          :name => new_resource.name,
          :hostid => template_ids.first['hostid']
        }
      }
      connection.query(request)
    end
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
