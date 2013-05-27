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
          :filter => {
            :description => new_resource.trigger_name
          }
        }
      }
      trigger_ids = connection.query(get_trigger_request)
      if trigger_ids.empty?
        Chef::Application.fatal! "No trigger named '#{new_resource.trigger_name}' found"
      end
      trigger_id = trigger_ids.first['triggerid']

      Chef::Log.info "CHICKEN"
      Chef::Log.info trigger_ids.first

      go_req = { 
        :method => "trigger.getobjects",
        :param => {
          :triggerid => trigger_id
        }
      }
      Chef::Log.info "CHICKEN"
      Chef::Log.info connection.query(go_req)


      get_dependency_request = {
        :method => "trigger.get",
        :params => {
          :filter => {
            :description => new_resource.dependency_name
          }
        }
      }
      dependency_ids = connection.query(get_dependency_request)
      if dependency_ids.empty?
        Chef::Application.fatal! "No trigger named '#{new_resource.dependency_name}' found"
      end
      dependency_id = dependency_ids.first['triggerid']

      add_dependency_request = {
        :method => "trigger.adddependencies",
        :params => {
          :triggerid => trigger_id,
          :dependsOnTriggerid => dependency_id,
        }
      }
      connection.query(add_dependency_request)

    end
end
