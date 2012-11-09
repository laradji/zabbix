describe 'zabbix::agent' do
  it 'runs as a daemon' do
    service(node['zabbix']['zabbix_agentd']).must_be_running
  end
end