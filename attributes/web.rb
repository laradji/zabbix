default['zabbix']['web']['login'] = "admin"
default['zabbix']['web']['password'] = "zabbix"
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


