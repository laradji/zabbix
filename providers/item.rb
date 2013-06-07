action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

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

      method = "item.create"
      params = {
        :name => new_resource.name,
        :description => new_resource.description,
        :key_ => new_resource.key,
        :hostid => template_id,
        :applications => application_ids,
        :type => new_resource.type.value,
        :value_type => new_resource.value_type.value, 
        :delay => new_resource.delay,
        :snmp_community => new_resource.snmp_community,
        :snmp_oid => new_resource.snmp_oid,
      }
      unless new_resource.port.to_s.empty?
        params[:port] = new_resource.port.to_s
      end

      item_ids = Zabbix::API.find_item_ids(connection, template_id, new_resource.key, new_resource.name)
      unless item_ids.empty?
        method = "item.update"
        params[:itemid] = item_ids.first['itemid']
      end

      connection.query(:method => method,
                       :params => params)
    end

    new_resource.updated_by_last_action(true)
end
