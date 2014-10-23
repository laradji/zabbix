action :create_or_update do
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

    noun = 'trigger'
    verb = 'create'

    # Check to see if this trigger name already exists
    if new_resource.prototype
      noun = 'triggerprototype'
      trigger_ids = Chef::Zabbix::API.find_trigger_prototype_ids(connection, new_resource.name, new_resource.expression)
    else
      trigger_ids = Chef::Zabbix::API.find_trigger_ids(connection, new_resource.name, new_resource.expression)
    end

    unless trigger_ids.empty?
      params[:triggerid] = trigger_ids.first['triggerid']
      verb = 'update'
    end

    method = "#{noun}.#{verb}"
    connection.query(
      :method => method,
      :params => params
    )
  end
  new_resource.updated_by_last_action(true)
end

action :delete do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    # NOTE: Triggers in the zabbix api don't really have a "name"
    # Instead we call it name so that lwrp users don't lose their minds
    # and we just treat it as the description field the api wants
    #
    trigger_ids = Chef::Zabbix::API.find_trigger_ids(connection, new_resource.name, new_resource.expression)
    if !trigger_ids.empty?
      # This *shouldn't* return more then one trigger_id, but just to be safe we'll just map the list
      params = trigger_ids.map { |t| t['triggerid'] }
      connection.query(
        :method => 'trigger.delete',
        :params => params
      )
    else
      # Nothing to update, move along
      Chef::Log.debug "trigger:delete:Could not find a trigger named #{new_resource.name} with expression '#{new_resource.expression}', nothing to delete"
    end

    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
