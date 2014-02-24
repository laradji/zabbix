action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    # Convert the "hostname" (a template name) into a hostid

    template_id=""
    if new_resource.template
      template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
      if template_ids.empty?
        Chef::Application.fatal! "Could not find a template named #{new_resource.template}"
      end
      template_id = template_ids.first['templateid']
    end
    if new_resource.hostname
      template_ids = Zabbix::API.find_host_ids(connection, new_resource.hostname)
      if template_ids.empty?
        Chef::Application.fatal! "Could not find a host named #{new_resource.hostname}"
      end
      template_id = template_ids.first['hostid']
    end

    #application_ids = Zabbix::API.find_application_ids(connection, new_resource.name, template_ids.first)
    application_ids = Zabbix::API.find_application_ids(connection, new_resource.name, template_id)

    if application_ids.empty?
      request = {
        :method => "application.create",
        :params => {
          :name => new_resource.name,
          :hostid => template_id
        }
      }
      connection.query(request)
    end
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe "zabbix::_providers_common"
  require 'zabbixapi'
end
