chef_gem 'zabbixapi' do
  action :install
  server_version = node['zabbix']['server']['version'].scan(/^\d+\.\d+/).first

  case server_version
  when '1.8'
    version '~> 0.6.3'
  when '2.0', '2.2', '2.4', '3.0'
    version "~> #{server_version}.0"
  when '3.2'
    version '~> 3.0.0'
  end
end
