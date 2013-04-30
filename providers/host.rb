action :create_or_update do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    group_ids = []
    new_resource.groups.map do |group|
      group_ids += [ :groupid => ( connection.hostgroups.get_id(:name => group) ||
        connection.hostgroups.create(:host => group) ) ]
    end

    interfaces = [
      {
        :type => 1,
        :main => 1,
        :ip => '',
        :port => 10050,
        :dns => new_resource.hostname,
        :useip => 0
      }
    ]

    connection.hosts.create_or_update(
      :host => new_resource.hostname,
      :interfaces => interfaces,
      :groups => group_ids
    )
  end

  new_resource.updated_by_last_action(true)
end
