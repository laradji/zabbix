if node['zabbix']['agent']['install_method'] == "package"
  include_recipe "zabbix::common"
else 
  include_recipe "zabbix::_agent_common_user"
  include_recipe "zabbix::common"
  include_recipe "zabbix::_agent_common_directories"
end
include_recipe "zabbix::_agent_common_service"
