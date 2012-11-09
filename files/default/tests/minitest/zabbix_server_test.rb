require File.expand_path('../support/helpers.rb', __FILE__)

describe 'zabbix::server' do
  it 'runs as a daemon' do
    service(node['zabbix']['zabbix_server']).must_be_running
  end
end