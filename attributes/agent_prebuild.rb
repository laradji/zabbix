include_attribute 'zabbix::agent'

default['zabbix']['agent']['prebuild']['arch']  = node['kernel']['machine'] == 'x86_64' ? 'amd64' : 'i386'
default['zabbix']['agent']['prebuild']['url']      = "http://www.zabbix.com/downloads/#{node['zabbix']['agent']['version']}/zabbix_agents_#{node['zabbix']['agent']['version']}.linux2_6.#{node['zabbix']['agent']['prebuild']['arch']}.tar.gz"
default['zabbix']['agent']['checksum'] = 'ec3d19dcdf484f60bc4583a84a39a3bd59c34ba1e7f8abf9438606eb14b90211'
