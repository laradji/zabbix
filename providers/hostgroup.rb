action :create do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|

     hostgroupId = connection.query( :method => "hostgroup.get",
                              :params => {
                              :filter => {
                                 :name => new_resource.parameters[:name]
                              }
                           })
     if hostgroupId.size == 0
        connection.query( :method => "hostgroup.create", 
                          :params => new_resource.parameters
                        )
     end
  end

  new_resource.updated_by_last_action(true)
end
