action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'


    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
      # NOTE: Triggers in the zabbix api don't really have a "name"
      # Instead we call it name so that lwrp users don't lose their minds
      # and we just treat it as the description field the api wants
      # 
      # The description on the lwrp becomes comments in the api

      template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
      application_ids = Zabbix::API.find_application_ids(connection, new_resource.application, template_ids.first['templateid'])

      get_trigger_request = {
        :method => "trigger.get",
        :params => {
          :filter => {
            :hostid => template_ids.first['templateid'],
            :description => new_resource.name
          }

        }
      }
      trigger_ids = connection.query(get_trigger_request)


      params = {
        # For whatever reason triggers have a description and comments
        # instead of a name and description...
        :description => new_resource.name,
        :comments => new_resource.description,
        :expression => new_resource.expression,
        :priority => new_resource.priority.value, #possibly -1?
        :status => new_resource.status.value,
        :hostid => template_ids.first['hostid'],
        :applications => application_ids.map { |app_id| app_id['applicationid'] }
      }
      method = "trigger.create"

      unless trigger_ids.empty?
        # Send the update request to the server
        params[:triggerid] = trigger_ids.first['triggerid']
        method = 'trigger.update'
      end
      connection.query(:method => method,
                       :params => params)
    end
    new_resource.updated_by_last_action(true)
end
