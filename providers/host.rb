action :create_or_update do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    group_ids = new_resource.groups.map do |group|
      id = connection.hostgroups.get_id(:name => group)
      if id.nil?
        if new_resource.force_group_creation
          id = connection.hostgroups.create(:name => group)
        else
          raise HostGroupNotFoundError(group)
        end
      end
      id
    end

    interfaces = new_resource.interfaces.empty? ?
      [ Chef::Zabbix::HostInterface.dns(new_resource.hostname) ] :
      new_resource.interfaces

    connection.hosts.create_or_update(
      :host => new_resource.hostname,
      :interfaces => interfaces.map(&:to_argument),
      :groups => group_ids.map { |id| { "groupid" => id } }
    )
  end

  new_resource.updated_by_last_action(true)
end
