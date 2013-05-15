action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
        # turn the name into an Id
        new_resource.parameters[:gitems].each do |gitem|
            itemId = connection.query( :method => "item.get",
                                       :params => {
                                           :hostids => connection.templates.get_id( :name => gitem[:hostName] ),
                                           :search => {
                                               :key_ => gitem[:key],
                                               :hostname => gitem[:hostName] }
                                              })
            gitem[:itemid] = itemId[0]['itemid']
            # remove the unused data
            gitem.delete(:key)
            gitem.delete(:hostName)
        end

        # Convert the "hostname" (a template name) into a hostid
        hostId = connection.query( :method => "template.get",
                                   :params => {
                                       :filter => {
                                           :host => new_resource.parameters[:hostName]}
                                              })
        # does this graph exist?
        graphId = connection.query( :method => "graph.get",
                                    :params => {
                                        :filter => {
                                            :name => new_resource.parameters[:name]},
                                        :search => {
                                            :hostid => hostId,},
                                                   })

        if graphId.size == 0
            # Send the creation request to the server
            connection.query( :method => "graph.create",
                             :params => new_resource.parameters
                            )
           else
               # Send the update request to the server
               new_resource.parameters[:graphid] = graphId[0]['graphid']
               connection.query( :method => "graph.update",
                                 :params => new_resource.parameters
                               )
        end
    end
    new_resource.updated_by_last_action(true)
end
