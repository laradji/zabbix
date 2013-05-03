default['zabbix']['agent']['install']           = true

default['zabbix']['agent']['branch']            = "ZABBIX%20Latest%20Stable"
default['zabbix']['agent']['version']           = "2.0.3"
default['zabbix']['agent']['servers']           = []
default['zabbix']['agent']['servers_active']    = []
default['zabbix']['agent']['hostname']          = node['fqdn']
default['zabbix']['agent']['configure_options'] = [ "--with-libcurl" ]
default['zabbix']['agent']['install_method']    = "prebuild"
default['zabbix']['agent']['include_dir']       = "/opt/zabbix/agent_include"

default['zabbix']['agent']['groups']            = [ "chef-agent" ]
