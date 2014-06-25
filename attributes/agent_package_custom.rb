#
# Cookbook Name:: zabbix
# Attributes:: agent_package_custom

default['zabbix']['agent_package_custom']['custom_repo_recipe'] = nil #'zabbix::_repos'
default['zabbix']['agent_package_custom']['package_name'] = 'zabbix-agent'
default['zabbix']['agent_package_custom']['package_version'] = nil
default['zabbix']['agent_package_custom']['package_action'] = 'install'
default['zabbix']['agent_package_custom']['package_options'] = nil
