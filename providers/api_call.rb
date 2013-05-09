def validate_data_type(connection, data_type)
  raise InvalidDataTypeError(data_type) unless connection.respond_to?(data_type)
end

def validate_method(data_type, method)
  raise InvalidApiMethodError(data_type, method) unless connection.respond_to?(data_type)
end

def validate_parameters(parameters)
  raise InvalidParametersHashError.new(parameters) unless parameters.is_a?(Hash)
end

action :call do

  zabbix_api_dependencies

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    validate_data_type(connection, new_resource.data_type)
    data_type = connection.send(new_resource.data_type)

    validate_method(data_type, new_resource.method)
    data_type.send(new_resource.method, new_resource.json)
  end

  new_resource.updated_by_last_action(true)
end
