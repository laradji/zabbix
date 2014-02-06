action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    # NOTE: Triggers in the zabbix api don't really have a "name"
    # Instead we call it name so that lwrp users don't lose their minds
    # and we just treat it as the description field the api wants
    # 
    # The description on the lwrp becomes comments in the api
    
    # NOTE 2 :
    # A trriger attribut depends on a name and a host/template
    # In this case we consider that trigger are applied by template, and dependency are between host
    # So that we need to retrieve the current host id and the host id of the templace dependency

    # Params : 
    # new_resource.hostdep_name : name of the host on which we depend, retrieve from an attribut (see recipes/agent_registration.rb)
    # If this params doesn't exist we considere that the dependency is between triggers belongin to the same host.
    # new_resource.dependency_name : the name of the trigger on which we will depend
    # new_resource.trigger_name : the name of the trigger on which we will applied a dependency
    # dep_host : host id of the host on which the trigger will depends on
    # my_hostid : host id of the current node
    # 
    
    #Retrieve the hostid of the trigger dependency
    dep_host=""
    if (new_resource.hostdep_name) 
      get_host_request = {
        :method => "host.get",
        :params => {
        :filter => {
        :host => new_resource.hostdep_name
      }
      }
      }
      dep_host = connection.query(get_host_request)
      if dep_host.size == 0 
        Chef::Application.fatal! "Host dependency #{new_resource.hostdep_name} no found"
      end
    else
      get_host_request = {
        :method => "host.get",
        :params => {
        :filter => {
        :host => new_resource.node["hostname"]
      }
      }
      }
      dep_host = connection.query(get_host_request)
      if hosts.size == 0
        Chef::Application.fatal! "Host dependency #{new_resource.hostdep} no found"
      end
    end
    dep_host=dep_host.to_s.gsub!(/\D/, "")

    #Retrieve the host id of the current host
    get_host_request = {
      :method => "host.get",
      :params => {
      :filter => {
      :host => new_resource.node["hostname"]
    }
    }
    }
    my_hostid = connection.query(get_host_request)
    if my_hostid.size == 0
      Chef::Application.fatal! "Host dependency #{my_hostid} no found"
    end
    my_hostid=my_hostid.to_s.gsub!(/\D/, "")

    #Retrieve the trigger id of my host
    get_trigger_request = {
      :method => "trigger.get",
      :params => {
      :filter => {
      :description => new_resource.trigger_name,
      :hostid =>  my_hostid
    },
      :selectDependencies => "refer"
    }
    }
    triggers = connection.query(get_trigger_request)
    if triggers.empty?
      Chef::Application.fatal! "No trigger named '#{new_resource.trigger_name}' for #{new_resource.node["hostname"]}:#{my_hostid} found"
    end
    trigger = triggers.first
    #Retrieve the trigger id of the host which I depend
    get_dependency_request = {
      :method => "trigger.get",
      :params => {
      :filter => {
      :description => new_resource.dependency_name,
      :hostid => dep_host
    }
    }
    }
    dependency_ids = connection.query(get_dependency_request)
    if dependency_ids.empty?
      Chef::Application.fatal! "No trigger dependency named '#{new_resource.dependency_name}' found"
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
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "Trigger '#{new_resource.trigger_name}' already depends on a trigger named '#{new_resource.dependency_name}'"
    end

  end
end

def load_current_resource
  run_context.include_recipe "zabbix::_providers_common"
  require 'zabbixapi'
end
