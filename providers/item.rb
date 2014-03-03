action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
    if template_ids.empty?
      Chef::Application.fatal! "Could not find a template named #{new_resource.template}"
    end

    template_id = template_ids.first['hostid']

    application_ids = new_resource.applications.map do |application|
      app_ids = Zabbix::API.find_application_ids(connection, application, template_id)
      if app_ids.empty?
        Chef::Application.fatal! "Could not find an application named #{application}"
      end
      app_ids.map { |app_id| app_id['applicationid'] }
    end.flatten

    noun = (new_resource.discovery_rule_key.nil?) ? 'item' : 'itemprototype'
    verb = 'create'

    params = {}
    simple_value_keys = [
      :name, :delay, :description, :snmp_community, :snmp_oid,
      :port, :params, :multiplier, :history, :trends, :allowed_hosts,
      :units, :snmpv3_securityname, :snmpv3_authpassphrase, :snmpv3_privpassphrase,
      :formula, :delay_flex, :ipmi_sensor, :username, :password,
      :publickey, :privatekey, :inventory_link, :valuemap,
    ]
    simple_value_keys.each do |key|
      params[key] = new_resource.send(key)
    end

    enum_value_keys = [
      :type, :value_type, :status, :delta, :snmpv3_securitylevel,
      :data_type, :authtype,
    ]
    enum_value_keys.each do |key|
      params[key] = new_resource.send(key).value
    end

    params[:params] = new_resource.item_params
    params[:key_] = new_resource.key
    params[:hostid] = template_id
    params[:applications] = application_ids
    unless new_resource.discovery_rule_key.nil?
      discovery_rule_id = Zabbix::API.find_lld_rule_ids(connection, template_id, new_resource.discovery_rule_key).first['itemid']
      params[:ruleid] = discovery_rule_id
    end

    if new_resource.discovery_rule_key.nil?
      item_ids = Zabbix::API.find_item_ids(connection, template_id, new_resource.key, new_resource.name)
    else
      item_ids = Zabbix::API.find_item_prototype_ids(connection, template_id, new_resource.key, discovery_rule_id)
    end

    unless item_ids.empty?
      verb = 'update'
      params[:itemid] = item_ids.first['itemid']
    end

    connection.query(
      :method => "#{noun}.#{verb}",
      :params => params
    )
  end

  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
