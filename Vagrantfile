# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrantfile needs the vagrant-omnbius plugin installed
# To install this, run "vagrant plugin install vagrant-omnibus"

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vbox|
    vbox.customize ['modifyvm', :id,
                    '--memory', 1024]
  end

  config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

  config.vm.hostname = "zabbix-berkshelf"
  server_ip = "192.168.50.10"
  config.vm.network :private_network, ip: server_ip

  config.omnibus.chef_version = "11.6.2"
  config.vm.provision :chef_solo do |chef|
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

    #chef.log_level = :debug
  end
end
