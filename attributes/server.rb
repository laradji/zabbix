default['zabbix']['server']['version']                = "2.0.3"
default['zabbix']['server']['branch']                 = "ZABBIX%20Latest%20Stable"
default['zabbix']['server']['source_url']             = nil
default['zabbix']['server']['install_method']         = "source"
default['zabbix']['server']['configure_options']      = [ "--with-libcurl","--with-net-snmp"]
default['zabbix']['server']['include_dir']            = "/opt/zabbix/server_include"
default['zabbix']['server']['log_level']              = 3
default['zabbix']['server']['housekeeping_frequency'] = "1"
default['zabbix']['server']['max_housekeeper_delete'] = "100000"
 
default['zabbix']['server']['host'] = "localhost"
default['zabbix']['server']['port'] = 10051
default['zabbix']['server']['name'] = nil
