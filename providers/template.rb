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
        puts "templateID.."
        puts templateId
        if templateId.size == 0
            connection.query( :method => "template.create",
                              :params => new_resource.parameters,
                            )
        end
    end
    new_resource.updated_by_last_action(true)
end
