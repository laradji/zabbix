include_recipe "zabbix::_repository"

package "zabbix-agent" do
  action :install
end

#include_recipe "zabbix::common"
