action :create_or_update do
  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end
  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    get_host_request = {
      :method => "host.get",
      :params => {
        :filter => {
          :host => new_resource.hostname
        }
      }
    }
    hosts = connection.query(get_host_request)

    if hosts.size == 0
      run_action :create
    else
      run_action :update
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

action :create do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end
  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    all_are_host_interfaces = new_resource.interfaces.all? { |interface| interface.kind_of?(Chef::Zabbix::API::HostInterface) }
    unless all_are_host_interfaces 
      Chef::Application.fatal!(":interfaces must only contain Chef::Zabbix::API::HostInterface")
    end

    get_groups_request = {
      :method => "hostgroup.get",
      :params => {
        :filter => {
          :name => new_resource.groups
        }
      }
    }
    groups = connection.query(get_groups_request).map { |group| group['groupid'] }

    get_templates_request = {
      :method => "template.get",
      :params => {
        :filter => {
          :name => new_resource.templates
        }
      }
    }

    templates = connection.query(get_templates_request).map { |template| template['templateid'] }

    request = {
      :method => "host.create",
      :params => {
        :host => new_resource.hostname,
        :groups => groups,
        :templates => templates,
        :interfaces => new_resource.interfaces.map(&:to_hash),
        :macros => format_macros(new_resource.macros)
      }
    }
    connection.query(request) 
  end
end

action :update do
  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

    get_host_request = {
      :method=>"host.get",
      :params=> {
        :filter=> {
          :host=>new_resource.hostname
        },
        :selectInterfaces=>"extend",
        :selectGroups=>"extend",
        :selectParentTemplates=>"extend"
      }
    }
    host = connection.query(get_host_request).first
    if host.nil?
      Chef::Application.fatal! "Could not find host #{new_resource.hostname}"
    end

    desired_groups = new_resource.groups.inject([]) do |acc, desired_group|
      get_desired_groups_request = {
        :method => "hostgroup.get",
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

    desired_templates = new_resource.templates.inject([]) do |acc, desired_template|
      get_desired_templates_request = {
        :method => "template.get",
        :params => {
          :filter => {
            :host => desired_template
          }
        }
      }
      template = connection.query(get_desired_templates_request)
      acc << template
    end

    existing_interfaces = host["interfaces"].values.map { |interface| Chef::Zabbix::API::HostInterface.from_api_response(interface).to_hash }
    new_host_interfaces = determine_new_host_interfaces(existing_interfaces, new_resource.interfaces.map(&:to_hash))

    host_update_request = {
      :method => "host.update",
      :params => {
        :hostid => host["hostid"],
        :groups => desired_groups,
        :templates => desired_templates.flatten,
      }
    }
    connection.query(host_update_request)

    new_host_interfaces.each do |interface|
      create_interface_request = {
        :method => "hostinterface.create",
        :params => interface.merge(:hostid => host["hostid"])

      }
      connection.query(create_interface_request)
    end

  end
  new_resource.updated_by_last_action(true)
end

def determine_new_host_interfaces(existing_interfaces, desired_interfaces)
  desired_interfaces.reject do |desired_interface|
    existing_interfaces.any? do |existing_interface|
      existing_interface["type"] == desired_interface["type"] &&
        existing_interface["port"] == desired_interface["port"]
    end
  end
end

