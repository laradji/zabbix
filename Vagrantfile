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

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
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
          'dbpassword' => 'password123'
        }
      }
    }

    chef.run_list = [
      "recipe[mysql::server]",
      "recipe[zabbix::default]",
      "recipe[zabbix::server]"
    ]
  end
end
