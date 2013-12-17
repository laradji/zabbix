# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrantfile needs the vagrant-omnbius plugin installed
# To install this, run "vagrant plugin install vagrant-omnibus"

BASE_IP = "192.168.50"
server_ip = "#{BASE_IP}.10"
client_ip = "#{BASE_IP}.11"

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vbox|
    vbox.customize ['modifyvm', :id,
                    '--memory', 1024]
  end

  config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"
  config.omnibus.chef_version = "11.6.2"

  config.vm.define "zabbix-server", :primary => true do |machine|
    
    machine.vm.hostname = "zabbix-server"
    machine.vm.network :private_network, ip: server_ip

    machine.vm.provision :chef_solo do |chef|
      chef.json = {
        :mysql => {
          :server_root_password => 'rootpass',
          :server_debian_password => 'debpass',
          :server_repl_password => 'replpass'
        },
        'postgresql' => {
          'password' => {
            'postgres' => 'rootpass'
          }
        },
        'zabbix' => {
          'agent' => {
            'servers' => [server_ip],
            'servers_active' => [server_ip]
          },
          'web' => {
            'install_method' => 'apache',
            'fqdn' => server_ip
          },
          'server' => {
            'install' => true,
            'ipaddress' => server_ip
          },
          'database' => {
            #'dbport' => '5432',
            #'install_method' => 'postgres',
            'dbpassword' => 'password123'
          }
        }
      }
      
      chef.add_recipe "database::mysql"
      chef.add_recipe "mysql::server"
      chef.add_recipe "zabbix"
      chef.add_recipe "zabbix::database"
      chef.add_recipe "zabbix::server"
      chef.add_recipe "zabbix::web"
      chef.add_recipe "zabbix::agent_registration"
    end
  end
  config.vm.define "zabbix-agent", :primary => true do |machine|
    
    machine.vm.hostname = "zabbix-agent"
    machine.vm.network :private_network, ip: client_ip
    
    machine.vm.provision :chef_solo do |chef|
      chef.json = {
        'zabbix' => {
          'agent' => {
            'install_method' => 'package',
            'servers' => [server_ip],
            'servers_active' => [server_ip]
          },
          'web' => {
            'fqdn' => server_ip
          }
        }
      }
      
      chef.add_recipe "zabbix"
      chef.add_recipe "zabbix::agent_registration"
    end
  end
end
    
