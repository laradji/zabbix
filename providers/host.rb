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

    if hostId.size == 0
      run_action :create
    else
      run_action :update
    end
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
        :groups => groups,
        :templates => templates,
        :interfaces => new_resource.interfaces.map(&:to_hash)
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

  Chef::Log.info("Found a server with that name, updating..")
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    groupId = connection.query( :method => "hostgroup.get",
                               :params =>
    {
      :filter =>
      {
        :name => new_resource.parameters[:groupNames]
      }
    })
    # create groups if they don't exist
    new_resource.parameters[:groups] = []
    if groupId.size < 1
      Chef::Log.info( "Groups not found, creating groups for you.." )
      new_resource.parameters[:groupNames].each do |group|
        groupId = connection.query( :method => "hostgroup.create",
                                   :params =>
        {
          :name => group
        }
                                  )
                                  new_resource.parameters[:groups].push( { :groupid => groupId['groupids'][0] } )
      end
    else
      new_resource.parameters[:groups] = groupId
    end
    new_resource.parameters.delete( :groupNames )

    hostId = connection.query( :method => "host.get",
                              :params =>
    {
      :filter =>
      {
        :host => new_resource.hostname
      }
    })


    # Update the host
    new_resource.parameters[:hostid] = hostId[0]['hostid']
    # todo: test the result to make sure the command happened ok
    result = connection.query( :method => "host.update",
                              :params => new_resource.parameters
                             )
  end
  new_resource.updated_by_last_action(true)
end

action :link do
  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'


  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    hostId = connection.query( :method => "host.get",
                              :params => { 
      :filter => {:host => new_resource.hostname} 
    })
    # get the IDS of the templates in the array
    templateId = []
    linkTo = []
    new_resource.templates.each do |template|
      templateId = connection.query( :method => "template.get",
                                    :params => {
        :filter => {
          :host => template,}
      })
      linkTo.push( :templateid => templateId[0]['templateid'] ) 
    end
    connection.query( :method => "host.update",
                     :params => {
      :hostid => hostId[0]['hostid'],
      :templates =>  linkTo
    })
  end
  new_resource.updated_by_last_action(true)
end
