action :create do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
     # Test to see if the application already exists
     unless connection.query( :method => "trigger.get",
                              :params => {
                                 :filter => {
                                    :name => new_resource.parameters[:name]
                              }
                           })
        # Convert the "hostname" (a template name) into a hostid
        hostId = connection.query( :method => "template.get",
                                   :params => {
                                      :filter => {
                                         :host => new_resource.parameters[:hostName]
                                      }
                                   })
        appId = connection.query( :method => "application.get",
                                  :params => {
                                     :filter => {
                                        :name => new_resource.parameters[:applicationNames]
                                     }
                                   })
        # Make a new params with the correct parameters
        new_resource.parameters[:hostid] = hostId
        new_resource.parameters[:applications] = [ appId ]
        # Send the creation request to the server
        connection.query( :method => "item.create",
                          :params => new_resource.parameters
                        )
     end

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
