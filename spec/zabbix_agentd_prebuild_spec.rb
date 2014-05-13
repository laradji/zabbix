require 'spec_helper'

describe 'zabbix::agent_prebuild' do

  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
        .converge(described_recipe)
    end

    it 'includes `zabbix::agent_common` recipe' do
      expect(chef_run).to include_recipe('zabbix::agent_common')
    end


    it 'extract zabbix agent binaries' do
      expect(chef_run).to put_ark('zabbix').with(path: '/opt',
                                                 strip_components: 0)
    end
  end

  context 'on Centos 5.9' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: '5.9')
        .converge(described_recipe)
    end

    it 'includes `zabbix::agent_common` recipe' do
      expect(chef_run).to include_recipe('zabbix::agent_common')
    end

    it 'installs package redhat-lsb' do
      expect(chef_run).to install_package('redhat-lsb')
    end

    it 'extract zabbix agent binaries' do
      expect(chef_run).to put_ark('zabbix').with(path: '/opt',
                                                 strip_components: 0)
    end
  end

  context 'on Centos 6.0' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: '6.0')
        .converge(described_recipe)
    end

    it 'includes `zabbix::agent_common` recipe' do
      expect(chef_run).to include_recipe('zabbix::agent_common')
    end

    it 'installs package redhat-lsb' do
      expect(chef_run).to install_package('redhat-lsb')
    end

    it 'extract zabbix agent binaries' do
      expect(chef_run).to put_ark('zabbix').with(path: '/opt',
                                                 strip_components: 0)
    end
  end
end
