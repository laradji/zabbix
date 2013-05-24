action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'
 

    # Translate the name of the interface to a type
    # TODO: add error checking for bad interface names
    types = {}
    types['agent'] = 1
    types['SNMP'] = 2
    types['IPMI'] = 3
    types['JMX'] = 4
    type = types[new_resource.name]

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
       # Convert the "hostname" (a template name) into a hostid
       hostId = connection.query( :method => "host.get",
                                  :params => {
                                      :filter => {
                                           :host => new_resource.parameters[:hostName],},
                                             })

        interfaceId = connection.query( :method => "hostinterface.get",
                                        :params => {
                                            :hostids => hostId[0]['hostid'],
                                            :filter => {
                                                :type => type,
                                                }
                                                   })

        if interfaceId.size == 0
            # Make a new params with the correct parameters
            new_resource.parameters[:hostid] = hostId[0]['hostid']
            # Send the creation request to the server
            connection.query( :method => "application.create",
                              :params => new_resource.parameters
                            )
        else
            # Update the interface for this host
            new_resource.parameters[:interfaceid] = interfaceId[0]['interfaceid']
            new_resource.parameters.delete( 'hostName' )
            connection.query( :method => "hostinterface.update",
                              :params => new_resource.parameters
                            )
        end
    end
    new_resource.updated_by_last_action(true)
end
