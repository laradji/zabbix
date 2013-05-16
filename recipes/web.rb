node.default['zabbix']['web']['fqdn'] = node['fqdn'] if node['zabbix']['web']['fqdn'].nil?

include_recipe "zabbix::web_#{node['zabbix']['web']['install_method']}"
