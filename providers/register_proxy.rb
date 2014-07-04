# Un-registration is not currently supported and is probably
# better done through a CMDB like ServiceNow as a non-existent node
# can't really unregister itself.

include Chef::Zabbix::RegisterProxy

action :register do
  result = register_proxy(@new_resource.master, @new_resource.server_connection)
  # register_proxy() returns true if something was created, false otherwise
  new_resource.updated_by_last_action(result)
end
