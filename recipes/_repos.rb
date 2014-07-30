#
# Cookbook Name:: zabbix
# Recipe:: _repos
#
# Copyright (C) 2014 Jorge Espada
#
# Apache 2.0
#


case node['platform']
when 'ubuntu', 'debian'
  apt_repository 'zabbix' do
    uri "http://repo.zabbix.com/zabbix/#{node['zabbix']['major_version']}/#{node['platform']}"
    distribution node['lsb']['codename']
    key 'http://repo.zabbix.com/zabbix-official-repo.key'
    components ['main']
  end
when 'redhat', 'centos', 'scientific', 'oracle'
  include_recipe 'yum::epel'
  yum_key 'RPM-GPG-KEY-ZABBIX' do
    url 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
    action :add
  end
  yum_repository 'zabbix' do
    repo_name 'zabbix'
    description 'Zabbix'
    key 'RPM-GPG-KEY-ZABBIX'
    url "http://repo.zabbix.com/zabbix/#{node['zabbix']['major_version']}/rhel/$releasever/$basearch"
    action :add
  end
end
