# Author:: Kevin Maziere
# Cookbook Name:: zabbix
# Recipe:: agent_packages
#
# Copyright 2013, KBRW
#
# Apache 2.0
#

zabbix_server =search(:node,"role:zabbix-server AND chef_environment:#{node.chef_environment}").first

#unless zabbix_server.nil?

if zabbix_server


	bash "remove_prebuild_agent" do
	code <<-EOH
	if [[ -f /etc/init.d/zabbix_agentd ]]; then /etc/init.d/zabbix_agentd stop; fi
	if [[ -f /etc/init.d/zabbix-agent ]]; then /etc/init.d/zabbix-agent stop; fi
	rm -rf /opt/zabbix/*/zabbix_agent*
	rm -f /etc/zabbix/zabbix_agentd.conf
	rm -f /etc/init.d/zabbix_agentd
	rm -f /etc/init.d/zabbix-agent
	killall -9 zabbix_agentd
	EOH
	only_if { ::File.exists?("/opt/zabbix/sbin/zabbix_agentd") }
	end

	bash "install_agent" do
	cwd "/tmp"
	code <<-EOH
        cd /tmp/
	wget -O /tmp/zabbix_agent.deb #{node["zabbix"]["agent"]["package_url"]}/zabbix-agent_#{node["zabbix"]["agent"]["version"]}-1+precise_amd64.deb
        dpkg -P zabbix-agent
        dpkg -i /tmp/zabbix_agent.deb
	EOH
	not_if "/usr/sbin/zabbix_agentd -V|grep v#{node['zabbix']['agent']['version']}"
	end

	end
