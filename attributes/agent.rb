# Load default.rb to use node['zabbix']['etc_dir']
include_attribute "zabbix"

default['zabbix']['agent']['install']           = true

default['zabbix']['agent']['branch']            = "ZABBIX%20Latest%20Stable"
default['zabbix']['agent']['version']           = "2.0.3"
default['zabbix']['agent']['servers']           = []
default['zabbix']['agent']['servers_active']    = []
default['zabbix']['agent']['hostname']          = node['fqdn']
default['zabbix']['agent']['configure_options'] = [ "--with-libcurl" ]
default['zabbix']['agent']['include_dir']       = ::File.join( node['zabbix']['etc_dir'] , "agent_include")
default['zabbix']['agent']['enable_remote_commands'] = true

default['zabbix']['agent']['groups']            = [ "chef-agent" ]

case node['platform_family']
when "rhel", "debian"
  default['zabbix']['agent']['init_style']      = "sysvinit"
  default['zabbix']['agent']['install_method']  = "prebuild"
  default['zabbix']['agent']['pid_file']         = ::File.join(node['zabbix']['run_dir'], "zabbix_agentd.pid")
when "windows"
  default['zabbix']['agent']['init_style']      = "windows"
  default['zabbix']['agent']['install_method']  = "chocolatey"
end

default['zabbix']['agent']['log_file']           = nil # default (Syslog / windows event).
#default['zabbix']['agent']['log_file']           = ::File.join(node['zabbix']['log_dir'], "zabbix_agentd.log"
default['zabbix']['agent']['start_agents']       = nil # default (3)
default['zabbix']['agent']['debug_level']        = nil # default (3)
