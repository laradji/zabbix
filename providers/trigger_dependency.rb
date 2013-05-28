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
          },
          :selectDependencies => "refer"
        }
      }
      triggers = connection.query(get_trigger_request)
      if triggers.empty?
        Chef::Application.fatal! "No trigger named '#{new_resource.trigger_name}' found"
      end
      trigger = triggers.first

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

      unless trigger['dependencies'].map { |dep| dep['triggerid'] }.include?(dependency_id)
        add_dependency_request = {
          :method => "trigger.adddependencies",
          :params => {
            :triggerid => trigger['triggerid'],
            :dependsOnTriggerid => dependency_id,
          }
        }
        connection.query(add_dependency_request)
      else
        Chef::Log.info "Trigger '#{new_resource.trigger_name}' already depends on a trigger named '#{new_resource.dependency_name}'"
      end

    end
end
