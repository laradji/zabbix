# Load default.rb to use node['zabbix']['etc_dir']
include_attribute "zabbix"

default['zabbix']['agent']['install']           = true

default['zabbix']['agent']['branch']            = "ZABBIX%20Latest%20Stable"
default['zabbix']['agent']['version']           = "2.0.3"
default['zabbix']['agent']['servers']           = []
default['zabbix']['agent']['servers_active']    = []
default['zabbix']['agent']['hostname']          = node['fqdn']
default['zabbix']['agent']['configure_options'] = [ "--with-libcurl" ]
default['zabbix']['agent']['install_method']    = "prebuild"
default['zabbix']['agent']['include_dir']       = File.join( node['zabbix']['etc_dir'] , "agent_include")

default['zabbix']['agent']['groups']            = [ "chef-agent" ]

case node['platform']
when "rhel", "debian"
  default['zabbix']['agent']['init_style']      = "sysvinit"
else
  default['zabbix']['agent']['init_style']      = nil
end
