# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_ztc
#
# Apache 2.0
#

include_recipe 'mercurial'
include_recipe 'python'

mercurial "#{Chef::Config[:file_cache_path]}/ztc" do
  repository "https://bitbucket.org/rvs/ztc"
  reference "tip"
  action :sync
  notifies :run, "execute[install ztc]"
end

execute "install ztc" do
  cwd "#{Chef::Config[:file_cache_path]}/ztc"
  command "python setup.py install"
#  action :nothing
end

easy_install_package "psycopg2" do
  ignore_failure true
end
easy_install_package "pymongo" do
  ignore_failure true
end

case node['platform']
when "ubuntu","debian"
  package "lm-sensors"
when "redhat","centos","fedora"
  package "sensors"
else
  package "lm-sensors"
end
