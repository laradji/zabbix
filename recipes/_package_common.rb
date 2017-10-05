# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: _package_common
#
# Copyright 2011, Efactures
#
# Apache 2.0
#
case node['platform']
when 'ubuntu', 'debian'
  apt_repository 'zabbix' do
    uri node['zabbix']['agent']['package']['repo_uri']
    distribution node['lsb']['codename']
    components ['main']
    key node['zabbix']['agent']['package']['repo_key']
  end
when 'redhat', 'centos', 'scientific', 'oracle', 'amazon'
  yum_repository 'zabbix' do
    repositoryid 'zabbix'
    description 'Zabbix Official Repository - $basearch'
    baseurl node['zabbix']['agent']['package']['repo_uri']
    gpgkey node['zabbix']['agent']['package']['repo_key']
    sslverify false
    action :create
  end

  yum_repository 'zabbix-non-supported' do
    repositoryid 'zabbix-non-supported'
    description 'Zabbix Official Repository non-supported - $basearch'
    baseurl node['zabbix']['agent']['package']['repo_uri']
    gpgkey node['zabbix']['agent']['package']['repo_key']
    sslverify false
    action :create
  end
end
