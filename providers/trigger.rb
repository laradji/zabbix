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

    validate_method(data_type, new_resource.method)
    # Need to move some data around in params because the call is a little different for triggers
    # WHY? ...
    # get the templateId
    templateId = connection.templates.get_id(:host=>new_resource.parameters[:templateName])
    params = { :description => new_resource.parameters[:name],
               :expression => new_resource.parameters[:expression],
               :comments => new_resource.parameters[:description],
               :priority => new_resource.parameters[:priority],
               :status     => new_resource.parameters[:status],
               :templateid => 0,
               :type => new_resource.parameters[:type]
    }
    puts "Method valid, sending stuff.."
    puts params
    data_type.send(new_resource.method, params)
  end

  new_resource.updated_by_last_action(true)
end
