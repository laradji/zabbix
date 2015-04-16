chef_gem 'zabbixapi' do
  action :install
  version node['zabbix']['zabbixapi_version']
end
