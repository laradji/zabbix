root_dirs = [
  node['zabbix']['agent']['include_dir']
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    unless node['platform'] == "windows"
      owner "root"
      group "root"
      mode "755" 
    end
    recursive true
    notifies :restart, "service[zabbix_agentd]"
  end
end

# Get log directory from the agent's log file path
log_dir = File.dirname(node['zabbix']['agent']['log_file'])

# Create agent log directory and set permissons
# Will produce a CHEF-3694 warning if you use /var/log/zabbix since this is used elsewhere in the cookbook
directory log_dir do
  owner node['zabbix']['agent']['user'] 
  group node['zabbix']['agent']['group'] 
  mode "755"
  # Only execute this if zabbix can't write to it. This handles cases of
  # dir being world writable (like /tmp)
  # [ File.word_writable? doesn't appear until Ruby 1.9.x ]
  not_if "su #{node['zabbix']['agent']['user']} -c \"test -d #{log_dir} && test -w #{log_dir}\""
  recursive true
  notifies :restart, "service[zabbix_agentd]"
end
