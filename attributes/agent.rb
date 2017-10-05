# Load default.rb to use node['zabbix']['etc_dir']
include_attribute 'zabbix'

default['zabbix']['agent']['install']           = true
default['zabbix']['agent']['service_state']     = [:start, :enable]
default['zabbix']['agent']['service_name']       = 'zabbix_agentd'

default['zabbix']['agent']['branch']            = 'ZABBIX%20Latest%20Stable'
default['zabbix']['agent']['version']           = '2.2.0'
default['zabbix']['agent']['source_url']        = nil
default['zabbix']['agent']['servers']           = []
default['zabbix']['agent']['servers_active']    = []
default['zabbix']['agent']['hostname']          = node['fqdn']
default['zabbix']['agent']['configure_options'] = ['--with-libcurl']
default['zabbix']['agent']['include_dir']       = ::File.join(node['zabbix']['etc_dir'], 'agent_include')
default['zabbix']['agent']['enable_remote_commands'] = true
default['zabbix']['agent']['listen_port']       = '10050'
default['zabbix']['agent']['timeout']       	= '3'

default['zabbix']['agent']['config_file']               = ::File.join(node['zabbix']['etc_dir'], 'zabbix_agentd.conf')
default['zabbix']['agent']['userparams_config_file']    = ::File.join(node['zabbix']['agent']['include_dir'], 'user_params.conf')

default['zabbix']['agent']['groups']            = ['chef-agent']

case node['platform_family']
when 'rhel', 'debian'
  default['zabbix']['agent']['init_style']      = 'sysvinit'
  default['zabbix']['agent']['install_method']  = 'prebuild'
  default['zabbix']['agent']['pid_file']        = ::File.join(node['zabbix']['run_dir'], 'zabbix_agentd.pid')

  default['zabbix']['agent']['user']            = 'zabbix'
  default['zabbix']['agent']['group']           = node['zabbix']['agent']['user']

  default['zabbix']['agent']['shell']           = node['zabbix']['shell']
when 'windows'
  default['zabbix']['agent']['init_style']      = 'windows'
  default['zabbix']['agent']['install_method']  = 'chocolatey'
end

default['zabbix']['agent']['log_file']           = nil # default (Syslog / windows event).
# default['zabbix']['agent']['log_file']           = ::File.join(node['zabbix']['log_dir'], "zabbix_agentd.log"
default['zabbix']['agent']['start_agents']       = nil # default (3)
default['zabbix']['agent']['debug_level']        = nil # default (3)
default['zabbix']['agent']['templates']          = []
default['zabbix']['agent']['interfaces']         = ['zabbix_agent']
default['zabbix']['agent']['jmx_port']           = '10052'
default['zabbix']['agent']['zabbix_agent_port']  = '10050'
default['zabbix']['agent']['snmp_port']          = '161'

default['zabbix']['agent']['user_parameter'] = []
