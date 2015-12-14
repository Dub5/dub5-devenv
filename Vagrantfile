# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'hellocode/ruby-devenv64'

  config.ssh.forward_agent = true

  config.vm.network :private_network, ip: '192.168.11.4' #
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :forwarded_port, guest: 3443, host: 3443

  config.vm.synced_folder '.', '/vagrant', type: 'nfs'

  config.vm.provision :shell, path: 'scripts/setup.sh'

  config.vm.provider :virtualbox do |v|
    v.name = 'Dub5 Development Environment (new)'
    v.memory = 2048
    v.cpus = 2
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end
end
