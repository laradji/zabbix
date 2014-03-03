# RHEL 5 and below does not seem to support 
# managed home directories. 
manage_home = true # most distros do support managed home so leave at true
if (node['platform_family'] == "rhel")
  rhel_major = (node['platform_version'].match /^([0-9]+)\.[0-9]+/)[1].to_i
  if rhel_major <= 5
    manage_home = false
  end
end

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
    supports :manage_home=>manage_home
  end
end
