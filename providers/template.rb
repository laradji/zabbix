action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
        templateId = connection.query( :method => "template.get",
                                       :params => {
                                           :filter => {
                                               :host => new_resource.parameters[:host]}
                                                      })
        if templateId.size == 0
            connection.query( :method => "template.create",
                              :params => new_resource.parameters,
                            )
        end
    end
    new_resource.updated_by_last_action(true)
end

action :delete do
    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
        # Check to see if the Template exists
        templateId = connection.query( :method => "template.get",
                                       :params => {
                                           :filter => {
                                               :host => new_resource.parameters[:host]}
                                                  })
         if templateId.size > 0
             params = [ templateId[0]['templateid'] ]
             connection.query( :method => "template.delete",
                               :params => params,
                                )
        end
    end
    new_resource.updated_by_last_action(true)
end


