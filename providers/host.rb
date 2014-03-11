action :create_or_update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    get_host_request = {
      :method => 'host.get',
      :params => {
        :filter => {
          :host => new_resource.hostname
        }
      }
    }
    hosts = connection.query(get_host_request)

    if hosts.size == 0
      Chef::Log.info 'Proceeding to register this node to the Zabbix server'
      run_action :create
    else
      Chef::Log.debug 'Going to update this host'
      run_action :update
    end
  end
  new_resource.updated_by_last_action(true)
end

action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    all_are_host_interfaces = new_resource.interfaces.all? { |interface| interface.kind_of?(Chef::Zabbix::API::HostInterface) }
    unless all_are_host_interfaces
      Chef::Application.fatal!(':interfaces must only contain Chef::Zabbix::API::HostInterface')
    end

    params_incoming = new_resource.parameters

    Chef::Log.error('Please supply a group for this host!') if params_incoming[:groupNames].length == 0

    groups = []
    params_incoming[:groupNames].each do |current_group|
      Chef::Log.info "Checking for existence of group #{current_group}"
      get_groups_request = {
        :method => 'hostgroup.get',
        :params => {
          :filter => {
            :name => current_group
          }
        }
      }
      groups = connection.query(get_groups_request)
      if groups.length == 0 && new_resource.create_missing_groups
        Chef::Log.info "Creating group #{current_group}"
        make_groups_request = {
          :method => 'hostgroup.create',
          :params => {
            :name => current_group
          }
        }
        result = connection.query(make_groups_request)
        # And now fetch the newly made group to be sure it worked
        # and for later use
        groups = connection.query(get_groups_request)
        Chef::Log.error('Error creating groups, see Chef errors') if result.nil?
      elsif groups.length == 1
        Chef::Log.info "Group #{current_group} already exists"
      else
        Chef::Application.fatal! "Could not find group, #{current_group}, for this host and \"create_missing_groups\" is False (or unset)"
      end
    end

    if params_incoming[:templates].length == 0
      Chef::Log.warn 'Empty Zabbix template list for this host - not searching to see if templates exist'
      templates = {}
    else
      get_templates_request = {
        :method => 'template.get',
        :params => {
          :output => 'extend',
          :filter => {
            :name => params_incoming[:templates]
          }
        }
      }

      templates = Hash[connection.query(get_templates_request).map { |template| [template['templateid'], template['name']] }]
      if templates.length != params_incoming[:templates].length
        missing_elements = params_incoming[:templates] - templates.values
        Chef::Application.fatal! "Cannot find all templates associated with host, missing : #{missing_elements}"
      end
    end

    templates_to_send = []
    templates.keys.each do |key|
      templates_to_send.concat([{ 'templateid' => key }])
    end
    request = {
      :method => 'host.create',
      :params => {
        :host => new_resource.hostname,
        :groups => groups,
        :templates => templates_to_send,
        :interfaces => params_incoming[:interfaces].map(&:to_hash),
        :macros => format_macros(new_resource.macros)
      }
    }
    Chef::Log.info 'Creating new Zabbix entry for this host'
    connection.query(request)
  end
  new_resource.updated_by_last_action(true)
end

action :update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    get_host_request = {
      :method => 'host.get',
      :params => {
        :filter => {
          :host => new_resource.hostname
        },
        :selectInterfaces => 'extend',
        :selectGroups => 'extend',
        :selectParentTemplates => 'extend'
      }
    }
    host = connection.query(get_host_request).first
    if host.nil?
      Chef::Application.fatal! "Could not find host #{new_resource.hostname}"
    end

    params_incoming = new_resource.parameters
    group_names = params_incoming[:groupNames]

    desired_groups = group_names.reduce([]) do |acc, desired_group|
      get_desired_groups_request = {
        :method => 'hostgroup.get',
        :params => {
          :filter => {
            :name => desired_group
          }
        }
      }
      group = connection.query(get_desired_groups_request).first
      if group.nil?
        Chef::Application.fatal! "Could not find group '#{desired_group}'"
      end
      acc << group
    end

    templates = params_incoming[:templates]
    desired_templates = templates.reduce([]) do |acc, desired_template|
      get_desired_templates_request = {
        :method => 'template.get',
        :params => {
          :filter => {
            :host => desired_template
          }
        }
      }
      template = connection.query(get_desired_templates_request)
      acc << template
    end

    existing_interfaces = host['interfaces'].values.map { |interface| Chef::Zabbix::API::HostInterface.from_api_response(interface).to_hash }
    new_host_interfaces = determine_new_host_interfaces(existing_interfaces, params_incoming[:interfaces].map(&:to_hash))

    host_update_request = {
      :method => 'host.update',
      :params => {
        :hostid => host['hostid'],
        :groups => desired_groups,
        :templates => desired_templates.flatten,
      }
    }
    connection.query(host_update_request)

    new_host_interfaces.each do |interface|
      create_interface_request = {
        :method => 'hostinterface.create',
        :params => interface.merge(:hostid => host['hostid'])

      }
      connection.query(create_interface_request)
    end

  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end

def determine_new_host_interfaces(existing_interfaces, desired_interfaces)
  desired_interfaces.reject do |desired_interface|
    existing_interfaces.any? do |existing_interface|
      existing_interface['type'] == desired_interface['type'] &&
        existing_interface['port'] == desired_interface['port']
    end
  end
end

def format_macros(macros)
  macros.map do |macro, value|
    macro_name = (macro[0] == '{') ? macro : "{$#{macro}}"
    {
      :macro => macro_name,
      :value => value
    }
  end
end
