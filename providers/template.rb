action :create do

    chef_gem "zabbixapi" do
        action :install
        version "~> 0.5.9"
    end

    require 'zabbixapi'

    Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
      template_ids = Zabbix::API.find_template_ids(connection, new_resource.name)
      
      if template_ids.empty?
        group_ids = Zabbix::API.find_hostgroup_ids(connection, new_resource.group)

        if group_ids.empty?
          Chef::Application.fatal! "Couldn't find a Hostgroup called #{new_resource.group}"
        end

        create_template_request = {
          :method => "template.create",
          :params => { 
            :host => new_resource.name,
            :groups => group_ids.first
          }
        }
        connection.query(create_template_request)

      end
    end

    new_resource.updated_by_last_action(true)
end

=begin
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
      puts templateId[0]['templateid']
      params = [ templateId[0]['templateid'] ]
      puts params
      connection.query( :method => "template.delete",
                       :params => params
                      )
    end
  end
  new_resource.updated_by_last_action(true)
end
=end


