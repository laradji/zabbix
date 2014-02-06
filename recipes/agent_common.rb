#include_recipe "zabbix::_agent_common_user"
include_recipe "zabbix::common"
include_recipe "zabbix::_agent_common_directories"
include_recipe "zabbix::_agent_common_service"

zabbix_server = search(:node, "role:zabbix-server AND chef_environment:#{node.chef_environment}" ).first
if zabbix_server.length > 0

	zabbix_server_ip = (zabbix_server["cloud"]) ? zabbix_server["cloud"]["local_ipv4"] : [ zabbix_server["ipaddress"] ]
	node.set['zabbix']['agent']['servers'] = [ zabbix_server_ip ]
	node.set['zabbix']['web']['ip'] = zabbix_server_ip
end

