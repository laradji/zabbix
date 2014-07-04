# Only active proxies are currently supported by this cookbook
default['zabbix']['proxy']['enabled']                    = false
# IMPORTANT: Override the master server in your wrapper cookbook
default['zabbix']['proxy']['master']                     = nil
default['zabbix']['proxy']['install_method']             = 'source'
# We re-use the node['zabbix']['database']['install_method']
# for the proxy too - please override in wrapper cookbook to use
# sqlite. Default is MySQL
default['zabbix']['proxy']['database']['dbhost']         = nil # ignored if using sqlite
default['zabbix']['proxy']['database']['dbname']         = nil # ignored if using sqlite
default['zabbix']['proxy']['database']['dbport']         = nil # ignored if using sqlite
default['zabbix']['proxy']['database']['dbpassword']     = nil # ignored if using sqlite
if node['zabbix']['database']['install_method'] == 'sqlite'
  default['zabbix']['proxy']['database']['dbname']          = '/opt/zabbix/db/zabbix.sqlite'
else
  default['zabbix']['proxy']['database']['dbname']        = 'zabbix'
end
default['zabbix']['proxy']['pollers']                    = '5'
default['zabbix']['proxy']['config_frequency']           = '3600' # 1 hour by default
default['zabbix']['proxy']['data_sender_frequency']      = '1' # every second by default
default['zabbix']['proxy']['heartbeat_frequency']        = '60' # every minute by default
default['zabbix']['proxy']['proxy_offline_buffer']       = '1' # 1 hour buffer if master goes down
default['zabbix']['proxy']['cache_size']                 = '8M'
default['zabbix']['proxy']['log_file']                   = '/var/log/zabbix/zabbix_proxy.log'
