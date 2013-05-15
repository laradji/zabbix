action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
        # Swap data around because the trigger API is different
        new_resource.parameters[:comments] = new_resource.parameters[:description]
        new_resource.parameters[:description] = new_resource.parameters[:name]
        new_resource.parameters[:priority] = new_resource.parameters[:priority].to_i - 1

        # Convert the "hostname" (a template name) into a hostid
        hostId = connection.query( :method => "template.get",
                                   :params => {
                                       :filter => {
                                           :host => new_resource.parameters[:hostName]}
                                              })
        appId = connection.query( :method => "application.get",
                                  :params => {
                                      :filter => {
                                          :name => new_resource.parameters[:applicationNames]}
                                             })

        triggerId = connection.query( :method => "trigger.get",
                                     :params => {
                                         :filter => {
                                             :description => new_resource.parameters[:description]},
                                         :search => {
                                             :hostid => hostId,},
                                                })

        if triggerId.size == 0
            # Make a new params with the correct parameters
            new_resource.parameters[:hostid] = hostId[0]['hostid']
            new_resource.parameters[:applications] = [ appId[0]['applicationid'] ]
            # Remove the bad parameter
            new_resource.parameters.delete(:hostName)
            new_resource.parameters.delete(:applicationNames)
            # Send the creation request to the server
            connection.query( :method => "trigger.create",
                             :params => new_resource.parameters
                            )
           else
               # Send the update request to the server
               new_resource.parameters[:triggerid] = triggerId[0]['triggerid']
               connection.query( :method => "trigger.update",
                                 :params => new_resource.parameters
                               )
           end
    end
    new_resource.updated_by_last_action(true)
end
