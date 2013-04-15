#
# Cookbook Name:: zabbix
# Attributes:: default

default['zabbix']['agent']['install']           = true
default['zabbix']['agent']['branch']            = "ZABBIX%20Latest%20Stable"
default['zabbix']['agent']['version']           = "2.0.3"
default['zabbix']['agent']['servers']           = []
default['zabbix']['agent']['servers_active']    = []
default['zabbix']['agent']['hostname']          = node['fqdn']
default['zabbix']['agent']['configure_options'] = [ "--with-libcurl" ]
default['zabbix']['agent']['install_method']    = "prebuild"
default['zabbix']['agent']['include_dir']       = "/opt/zabbix/agent_include"

default['zabbix']['database']['install_method'] = "mysql"
default['zabbix']['database']['dbname']         = "zabbix"
default['zabbix']['database']['dbuser']         = "zabbix"
default['zabbix']['database']['dbhost']         = "localhost"
default['zabbix']['database']['dbpassword']     = nil
default['zabbix']['database']['dbport']         = "3306"

default['zabbix']['database']['rds_master_user']      = nil
default['zabbix']['database']['rds_master_password']  = nil

default['zabbix']['server']['version']  = "2.0.3"
default['zabbix']['server']['branch']   = "ZABBIX%20Latest%20Stable"
default['zabbix']['server']['install_method']         = "source"
default['zabbix']['server']['configure_options']      = [ "--with-libcurl","--with-net-snmp"]
default['zabbix']['server']['include_dir']            = "/opt/zabbix/server_include"
default['zabbix']['server']['log_level']              = 3
default['zabbix']['server']['housekeeping_frequency'] = "1"
default['zabbix']['server']['max_housekeeper_delete'] = "100000"
 
default['zabbix']['web']['install_method']  = 'apache'
default['zabbix']['web']['fqdn']            = nil
default['zabbix']['web']['aliases']         = ["zabbix"]
default['zabbix']['web']['port']            = 80
default['zabbix']['web']['php_settings']    = {
  "memory_limit"        => "256M",
  "post_max_size"       => "32M",
  "upload_max_filesize" => "16M",
  "max_execution_time"  => "600",
  "max_input_time"      => "600",
  "date.timezone"       => "'UTC'",
}

default['zabbix']['install_dir']  = "/opt/zabbix"
default['zabbix']['etc_dir']      = "/etc/zabbix"
default['zabbix']['web_dir']      = "/opt/zabbix/web"
default['zabbix']['external_dir'] = "/opt/zabbix/externalscripts"
default['zabbix']['alert_dir']    = "/opt/zabbix/AlertScriptsPath"
default['zabbix']['lock_dir']     = "/var/lock/subsys"
default['zabbix']['src_dir']      = "/opt"
default['zabbix']['log_dir']      = "/var/log/zabbix"
default['zabbix']['run_dir']      = "/var/run/zabbix"

default['zabbix']['login']  = "zabbix"
default['zabbix']['group']  = "zabbix"
default['zabbix']['uid']    = nil
default['zabbix']['gid']    = nil
default['zabbix']['home']   = '/opt/zabbix'
default['zabbix']['shell']  = "/bin/bash"
