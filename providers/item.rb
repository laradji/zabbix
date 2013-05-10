def validate_data_type(connection, data_type)
  puts data_type
  raise Chef::Zabbix::InvalidDataTypeError(data_type) unless connection.respond_to?(data_type)
end

def validate_method(data_type, method)
  puts data_type, method
  raise Chef::Zabbix::InvalidApiMethodError(method) unless data_type.respond_to?(method)
end

def validate_parameters(parameters)
  raise InvalidParametersHashError.new(parameters) unless parameters.is_a?(Hash)
end

action :call do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    validate_data_type(connection, new_resource.data_type)
    data_type = connection.send(new_resource.data_type)
    itemId = connection.items.get_id( :name=>new_resource.parameters[:name])
    validate_method(data_type, new_resource.method)
    puts "Method valid, sending stuff.."
    # turn the hostName into an id
    puts new_resource.parameters[:hostName]
    hostId = connection.templates.get_id(:host=>new_resource.parameters[:hostName])
    puts "Host ID: #{hostId}"

    appId = connection.applications.get_id(:name=>new_resource.parameters[:applicationNames])
    puts "App ID: #{appId}"
    params = { :name => new_resource.parameters[:name],
               :description => new_resource.parameters[:description],
               :key_ => new_resource.parameters[:key_],
               :hostid => hostId,
               :applications => [ appId ] 
       }
    puts params
    # doing it this way, and not with create_or_update avoids new checks being created if the name of the check changes
    if itemId.nil?
       method = "create"
    else
       method = "update"
    end
    puts method
    data_type.send(method, params)

 
  end

  new_resource.updated_by_last_action(true)
end
