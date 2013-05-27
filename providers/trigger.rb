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

      get_trigger_request = {
        :method => "trigger.get",
        :params => {
          :search => {
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
        :priority => new_resource.priority.value,
        :status => new_resource.status.value,
      }
      method = "trigger.create"

      unless trigger_ids.empty?
        10.times { Chef::Log.info("Found #{trigger_ids.first['triggerid']}") }
        # Send the update request to the server
        params[:triggerid] = trigger_ids.first['triggerid']
        method = 'trigger.update'
      end
      connection.query(:method => method,
                       :params => params)
    end
    new_resource.updated_by_last_action(true)
end
