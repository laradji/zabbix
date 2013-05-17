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

default['zabbix']['agent']['groups']            = [ "chef-agent" ]

default['zabbix']['agent']['prebuild']['arch']  = node['kernel']['machine'] == "x86_64" ? "amd64" : "i386"
default['zabbix']['agent']['prebuild']['url']      = "http://www.zabbix.com/downloads/#{node['zabbix']['agent']['version']}/zabbix_agents_#{node['zabbix']['agent']['version']}.linux2_6.#{node['zabbix']['agent']['prebuild']['arch']}.tar.gz"

case node['platform_family']
when "rhel", "debian"
  default['zabbix']['agent']['init_style']      = "sysvinit"
  default['zabbix']['agent']['install_method']  = "prebuild"
when "windows"
  default['zabbix']['agent']['init_style']      = "windows"
  default['zabbix']['agent']['install_method']  = "chocolatey"
end
