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

    connection.query( :method => new_resource.method, 
                      :params => new_resource.parameters
                    )
  end

  new_resource.updated_by_last_action(true)
end
