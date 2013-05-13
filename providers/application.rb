action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

        # Test to see if the application already exists
        appId =  connection.query( :method => "application.get",
                                   :params => {
                                       :filter => {
                                           :name => new_resource.parameters[:name]}
                                              })
        if appId.size == 0
            # Convert the "hostname" (a template name) into a hostid
            puts new_resource.parameters[:hostName]
            hostId = connection.query( :method => "template.get",
                                       :params => {
                                           :filter => {
                                               :host => new_resource.parameters[:hostName],},
                                                  })
            puts "Host Id? -> "
            puts hostId[0]
            # Make a new params with the correct parameters
            new_resource.parameters[:hostid] = hostId[0]['hostid']
            # Send the creation request to the server
            connection.query( :method => "application.create",
                              :params => new_resource.parameters
                            )
        end
    end
    new_resource.updated_by_last_action(true)
end
