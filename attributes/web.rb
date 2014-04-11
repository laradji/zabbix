default['zabbix']['web']['login'] = 'admin'
default['zabbix']['web']['password'] = 'zabbix'
default['zabbix']['web']['install_method']  = 'apache'
default['zabbix']['web']['fqdn']            = node['fqdn']
default['zabbix']['web']['aliases']         = ['zabbix']
default['zabbix']['web']['port']            = 80

default['zabbix']['web']['php']['fastcgi_listen'] = '127.0.0.1:9000' # only applicable when using php-fpm (nginx)
default['zabbix']['web']['php']['settings']    = {
  'memory_limit'        => '256M',
  'post_max_size'       => '32M',
  'upload_max_filesize' => '16M',
  'max_execution_time'  => '600',
  'max_input_time'      => '600',
  'date.timezone'       => "'UTC'",
}

default['zabbix']['web']['packages'] = value_for_platform_family(
  'debian' => %w(php5-mysql php5-gd libapache2-mod-php5),
  'rhel' =>
    if node['platform_version'].to_f < 6.0
      %w(php53-mysql php53-gd php53-bcmath php53-mbstring)
    else
      %w(php php-mysql php-gd php-bcmath php-mbstring php-xml)
    end
  )
