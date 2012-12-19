# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

# Create zabbix server group

if node['zabbix']['server']['gid'].nil?
  group node['zabbix']['server']['group']
else
# Assume the one who specified the GID knows what they are doing and change
# the group name if there is already a group with a different name using
# the GID.  Would be nice if "action :modify" could change a group name
# but seems the only way is to delete and recreate the group.
  node['etc']['group'].each do |grp, grpdata|
    if grpdata['gid'].to_i == node['zabbix']['server']['gid'].to_i
      Chef::Log.debug("gid #{grpdata['gid']} found for group #{grp}")
# Plus you get "groupdel: cannot remove the primary group of user"
# unless you delete any accounts that are using the group's gid.
      node['etc']['passwd'].each do |usr, userdata|
        if userdata['gid'].to_i == node['zabbix']['server']['gid'].to_i
          Chef::Log.info("Deleting user #{usr}")
# More nonsense: "userdel: user zbxsrv is currently logged in"
          service "zabbix_server" do
            action :stop
          end
          user usr do
            action :remove
          end
        end
      end
      Chef::Log.info("Deleting group #{grp}")
      group grp do
        action :remove
      end
      break
    end
  end
  group node['zabbix']['server']['group'] do
    gid node['zabbix']['server']['gid']
  end
end

# Create zabbix server User
action = :create
unless node['zabbix']['server']['uid'].nil?
  node['etc']['passwd'].each do |user, data|
    if data['uid'] == node['zabbix']['server']['uid']
      action = :modify
      break
    end
  end
end

user node['zabbix']['server']['login'] do
  comment "Zabbix Server User"
  home node['zabbix']['server']['install_dir']
  shell node['zabbix']['server']['shell']
  uid node['zabbix']['server']['uid']
  gid node['zabbix']['server']['gid']
  system true
  action action
end

# Define zabbix server owned folders
zabbix_dirs = [
  node['zabbix']['server']['log_dir'],
  node['zabbix']['server']['run_dir']
]

# Create zabbix folders
zabbix_dirs.each do |dir|
  directory dir do
    owner node['zabbix']['server']['login']
    group node['zabbix']['server']['group']
    mode "750"
    recursive true
    # Only execute this if zabbix server can't write to it. This handles cases of
    # dir being world writable (like /tmp)
    # [ File.word_writable? doesn't appear until Ruby 1.9.x ]
    not_if "su #{node['zabbix']['server']['login']} -c \"test -d #{dir} && test -w #{dir}\""
  end
end

if node['zabbix']['server']['install']
  include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"
  if node['zabbix']['agent']['install']
    unless node['zabbix']['agent']['servers'].include? "localhost"
      node.set['zabbix']['agent']['servers'].unshift "localhost"
    end
  end
end

if node['zabbix']['web']['install']
  include_recipe "zabbix::web"
end
