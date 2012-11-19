#
# Cookbook Name:: zabbix
# Attributes:: default

default['zabbix']['agent']['install'] = true
default['zabbix']['agent']['version'] = "2.0.3"
default['zabbix']['agent']['branch'] = "ZABBIX%20Latest%20Stable"
default['zabbix']['agent']['servers'] = []
default['zabbix']['agent']['servers_active'] = []
default['zabbix']['agent']['hostname'] = node['fqdn']
default['zabbix']['agent']['configure_options'] = [ "--with-libcurl" ]
default['zabbix']['agent']['install_method'] = "prebuild"
default['zabbix']['agent']['include_dir'] = "/opt/zabbix/agent_include"

default['zabbix']['server']['install'] = false
default['zabbix']['server']['version'] = "2.0.3"
default['zabbix']['server']['branch'] = "ZABBIX%20Latest%20Stable"
default['zabbix']['server']['dbname'] = "zabbix"
default['zabbix']['server']['dbuser'] = "zabbix"
default['zabbix']['server']['dbhost'] = "localhost"
default['zabbix']['server']['dbpassword'] = nil
default['zabbix']['server']['dbport'] = "3306"
default['zabbix']['server']['install_method'] = "source"
default['zabbix']['server']['configure_options'] = [ "--with-libcurl","--with-net-snmp","--with-mysql" ]
default['zabbix']['server']['include_dir'] = "/opt/zabbix/server_include"
default['zabbix']['server']['db_install_method'] = "mysql"
default['zabbix']['server']['rds_dbhost'] = nil
default['zabbix']['server']['rds_dbport'] = "3306"
default['zabbix']['server']['rds_master_user'] = nil
default['zabbix']['server']['rds_master_password'] = nil
default['zabbix']['server']['rds_dbname'] = "zabbix"
default['zabbix']['server']['rds_dbuser'] = "zabbix"
default['zabbix']['server']['rds_dbpassword'] = nil
default['zabbix']['server']['log_level'] = 3
default['zabbix']['server']['housekeeping_frequency'] = "1"
default['zabbix']['server']['max_housekeeper_delete'] = "100000"
 
default['zabbix']['web']['install'] = false
default['zabbix']['web']['fqdn'] = nil
default['zabbix']['web']['aliases'] = ["zabbix"]

default['zabbix']['install_dir'] = "/opt/zabbix"
default['zabbix']['etc_dir'] = "/etc/zabbix"
default['zabbix']['web_dir'] = "/opt/zabbix/web"
default['zabbix']['external_dir'] = "/opt/zabbix/externalscripts"
default['zabbix']['alert_dir'] = "/opt/zabbix/AlertScriptsPath"
default['zabbix']['lock_dir'] = "/var/lock/subsys"
default['zabbix']['src_dir'] = "/opt"
default['zabbix']['log_dir'] = "/var/log/zabbix"
default['zabbix']['run_dir'] = "/var/run/zabbix"

default['zabbix']['login'] = "zabbix"
default['zabbix']['group'] = "zabbix"
default['zabbix']['uid'] = nil
default['zabbix']['gid'] = nil
default['zabbix']['home'] = '/opt/zabbix'
default['zabbix']['shell'] = "/bin/bash"
