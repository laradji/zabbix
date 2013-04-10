# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vbox|
    vbox.customize ['modifyvm', :id,
                    '--memory', 1024]
  end

  config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

  config.vm.hostname = "zabbix-berkshelf"
  config.vm.network :private_network, ip: "192.168.50.10"

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.provision :shell, :inline => "sudo /opt/chef/embedded/bin/gem install chef -v 10.24.0"
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
          'servers' => ['127.0.0.1'],
          'servers_active' => ['127.0.0.1']
        },
        'web' => {
          'install' => true
        },
        'server' => {
          'install' => true,
        },
        'database' => {
          'dbport' => '5432',
          'install_method' => 'postgres',
          'dbpassword' => 'password123'
        }
      }
    }

    chef.run_list = [
      "recipe[yum::epel]",
      "recipe[database::mysql]",
      "recipe[mysql::server]",
      "recipe[database::postgresql]",
      "recipe[postgresql::server]",
      "recipe[postgresql::client]",
      "recipe[zabbix::default]",
      "recipe[zabbix::database]",
      "recipe[zabbix::server]"
    ]
  end
end
