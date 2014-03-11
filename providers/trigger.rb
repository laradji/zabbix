action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    # NOTE: Triggers in the zabbix api don't really have a "name"
    # Instead we call it name so that lwrp users don't lose their minds
    # and we just treat it as the description field the api wants
    #
    # The description on the lwrp becomes comments in the api

    params = {
      # For whatever reason triggers have a description and comments
      # instead of a name and description...
      :description => new_resource.name,
      :comments => new_resource.description,
      :expression => new_resource.expression,
      :priority => new_resource.priority.value,
      :status => new_resource.status.value,
    }

    noun = (new_resource.prototype) ? 'triggerprototype' : 'trigger'
    verb = 'create'

    if new_resource.prototype
      trigger_ids = Zabbix::API.find_trigger_prototype_ids(connection, new_resource.name)
    else
      trigger_ids = Zabbix::API.find_trigger_ids(connection, new_resource.name)
    end

    unless trigger_ids.empty?
      verb = 'update'
      params[:triggerid] = trigger_ids.first['triggerid']
    end

    method = "#{noun}.#{verb}"
    connection.query(
      :method => method,
      :params => params
    )
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
