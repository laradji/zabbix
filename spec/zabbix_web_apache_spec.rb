require 'spec_helper'

describe 'zabbix::web_apache' do
  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
        .converge(described_recipe)
    end

    it 'installs required packages' do
      %w(php5-mysql php5-gd libapache2-mod-php5).each do |package|
        expect(chef_run).to install_package(package)
      end
    end
  end

  context 'on Centos 5.9' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: '5.9')
        .converge(described_recipe)
    end

    it 'installs required packages' do
      %w(php53-mysql php53-gd php53-bcmath php53-mbstring).each do |package|
        expect(chef_run).to install_package(package)
      end
    end
  end

  context 'on Centos 6.0' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: '6.0')
        .converge(described_recipe)
    end

    it 'installs required packages' do
      %w(php php-mysql php-gd php-bcmath php-mbstring php-xml).each do |package|
        expect(chef_run).to install_package(package)
      end
    end
  end
end
