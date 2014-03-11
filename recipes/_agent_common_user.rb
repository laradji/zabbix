# Manage user and group
if node['zabbix']['agent']['user']
  # Create zabbix group
  group node['zabbix']['agent']['group'] do
    gid node['zabbix']['agent']['gid'] if node['zabbix']['agent']['gid']
    system true
  end

  # Create zabbix User
  user node['zabbix']['agent']['user'] do
    home node['zabbix']['install_dir']
    shell node['zabbix']['agent']['shell']
    uid node['zabbix']['agent']['uid'] if node['zabbix']['agent']['uid']
    gid node['zabbix']['agent']['gid'] || node['zabbix']['agent']['group']
    system true
    supports :manage_home => true
  end
end
