#include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
#include_recipe "zabbix::agent_common"

zabbix_server =search(:node,"role:zabbix-server AND chef_environment:#{node.chef_environment}").first

#unless zabbix_server.length.nil?
	if zabbix_server
	include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
	include_recipe "zabbix::agent_common"

	zabbix_server =search(:node,"role:zabbix-server AND chef_environment:#{node.chef_environment}").first

	node.default["monitoring"]["zabbix"]["template"]["base"]= ['Template OS Linux Base']

	# Install configuration
	template "zabbix_agentd.conf" do
		path node['zabbix']['agent']['config_file']
		source "zabbix_agentd.conf.erb"
		unless node['platform_family'] == "windows"
			owner "root"
			group "root"
			mode "644"
		end
		notifies :restart, "service[zabbix-agent]"
		variables({
			:zabbix_server => zabbix_server
		})
	end

	ruby_block "start service" do
		block do
			true
		end
		Array(node['zabbix']['agent']['service_state']).each do |action|
			notifies action, "service[zabbix-agent]"
		end
	end

	res=search(:virtual_machines,"id:#{node['hostname']}").first
	if res then
		
                hyp=res["host"]
                # Dirty trick to set end of fqdn hypervisor same as vm
                hyp=hyp.to_s.split('.', 2).first+"."+node["cloud"]["local_hostname"].to_s.split('.', 2).last
		#Setup hyp trigger dependencies here
		node.default['virtualization']['hypervisor']="#{hyp}"
                node.default['monitoring']['zabbix']['triggerdeps']["{HOST.NAME} : Ping ICMP"]= "#{hyp}: {HOST.NAME} : Ping ICMP"
		node.default['monitoring']['zabbix']['triggerdeps']["Lack of available memory on server {HOST.NAME}"]= "#{hyp}: Lack of available memory on server {HOST.NAME}"
	else
		Chef::Log.warn("Zabbix_LOG : #{node['hostname']} as not hypervisor defined in it's databags")
	end

	package "libnet-dns-perl"

end
