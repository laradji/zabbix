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
    notifies :restart, "service[zabbix-agent]"
  end
end

package "gawk" do
  action :install
end

# Create user scripts folder and files
remote_directory "/etc/zabbix/scripts_agentd" do
  source "scripts_agentd"
  files_owner "zabbix"
  files_group "root"
  files_mode 00750
  owner "zabbix"
  group "root"
  action :create
end
