# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: _package_common
#
# Copyright 2011, Efactures
#
# Apache 2.0
#
case node['platform']
  when "ubuntu", "debian"
    apt_repository 'zabbix' do
      uri          node['zabbix']['agent']['package']['repo_uri']
      distribution node['lsb']['codename']
      components   ["main"]
      key          node['zabbix']['agent']['package']['repo_key']
    end
  when "redhat", "centos", "fedora", "scientific", "amaxon"
    yum_repository 'zabbix' do
      baseurl node['zabbix']['agent']['package']['repo_uri']
      gpgkey  node['zabbix']['agent']['package']['repo_key']
    end
end
