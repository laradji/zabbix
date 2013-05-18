action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
        # Convert the "hostname" (a template name) into a hostid
        hostId = connection.query( :method => "template.get",
                                   :params => {
                                       :filter => {
                                           :host => new_resource.parameters[:hostName]}
                                              })
        new_resource.parameters[:applicationNames].each do |application|
            appId =  connection.query( :method => "application.get",
                                   :params => {
                                       :hostids => hostId[0]['hostid'],
                                       :filter => {
                                           :name => application[:applicationName]},
                                              })
 
            application[:applicationid] = appId[0]['applicationid']
            # remove the unused data
            application.delete(:applicationName)
        end


        itemId = connection.query( :method => "item.get",
                                   :params => {
                                       :hostids => hostId[0]['hostid'],
                                       :filter => { 
                                           :name => new_resource.parameters[:name],},
                                       :search => {
                                           :key_ => new_resource.parameters[:key_],},
                                              })
        if itemId.size == 0
            # Make a new params with the correct parameters
            new_resource.parameters[:hostid] = hostId[0]['hostid']
            # Remove the bad parameter
            new_resource.parameters.delete(:hostName)
            new_resource.parameters.delete(:applicationNames)
            # Send the creation request to the server
            connection.query( :method => "item.create",
                              :params => new_resource.parameters
                            )
        else
            # Add the item ID to params and send the udate
            new_resource.parameters[:itemid] = itemId[0]['itemid']
            connection.query( :method => "item.update",
                              :params => new_resource.parameters
                            )
        end
  end

  new_resource.updated_by_last_action(true)
end
