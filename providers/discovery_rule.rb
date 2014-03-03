action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
    if template_ids.empty?
      Chef::Application.fatal! "Could not find a template named #{new_resource.template}"
    end

    template_id = template_ids.first['hostid']

    method = 'discoveryrule.create'
    params = {}
    simple_value_keys = [
      :name, :delay, :lifetime, :delay_flex, :description,
      :filter, :ipmi_sensor, :password, :port, :privatekey,
      :publickey, :snmp_community, :snmp_oid, :snmpv3_securityname,
      :snmpv3_authpassphrase, :snmpv3_privpassphrase, :username
    ]
    simple_value_keys.each do |key|
      params[key] = new_resource.send(key)
    end

    enum_value_keys = [
      :type, :authtype, :snmpv3_securitylevel, :status
    ]
    enum_value_keys.each do |key|
      params[key] = new_resource.send(key).value
    end

    params[:hostid] = template_id
    params[:key_] = new_resource.key
    params[:params] = new_resource.discovery_rule_params
    params[:trapper_hosts] = new_resource.allowed_hosts

    rule_ids = Zabbix::API.find_lld_rule_ids(connection, template_id, new_resource.key)
    unless rule_ids.empty?
      method = 'discoveryrule.update'
      params[:itemid] = rule_ids.first['itemid']
    end

    connection.query(:method => method,
                     :params => params)
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
