include_attribute 'zabbix'

default['zabbix']['server']['version']                = '2.0.3'
default['zabbix']['server']['branch']                 = 'ZABBIX%20Latest%20Stable'
default['zabbix']['server']['source_url']             = nil
default['zabbix']['server']['install_method']         = 'source'
default['zabbix']['server']['configure_options']      = ['--with-libcurl', '--with-net-snmp']
default['zabbix']['server']['include_dir']            = '/opt/zabbix/server_include'
default['zabbix']['server']['log_file']               = ::File.join(node['zabbix']['log_dir'], 'zabbix_server.log')
default['zabbix']['server']['log_level']              = 3
default['zabbix']['server']['housekeeping_frequency'] = '1'
default['zabbix']['server']['max_housekeeper_delete'] = '100000'

default['zabbix']['server']['host'] = 'localhost'
default['zabbix']['server']['port'] = 10_051
default['zabbix']['server']['name'] = nil

default['zabbix']['server']['java_gateway'] = '127.0.0.1'
default['zabbix']['server']['java_gateway_port'] = 10_052
default['zabbix']['server']['java_pollers'] = 0
default['zabbix']['server']['start_pollers'] = 5

default['zabbix']['server']['externalscriptspath'] = '/usr/local/scripts/zabbix/externalscripts/'

default['zabbix']['server']['timeout'] = '3'
default['zabbix']['server']['value_cache_size'] = '8M' # default 8MB
default['zabbix']['server']['cache_size'] = '8M' # default 8MB
