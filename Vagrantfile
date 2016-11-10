# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'

  config.ssh.forward_agent = true

  config.vm.network :private_network, ip: '192.168.33.10'
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :forwarded_port, guest: 3443, host: 3443
  config.vm.network :forwarded_port, guest: 4000, host: 4000

  config.vm.synced_folder '.', '/vagrant', type: 'nfs'

  config.vm.provider :virtualbox do |v|
    v.name = 'Dub5 Development Environment'
    v.memory = 2048
    v.cpus = 2
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.vm.define "chopeo", autostart: false, primary: true do |chopeo|
    chopeo.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/playbook-chopeo.yml"
    end
  end

  config.vm.define "dub5", autostart: false do |dub5|
    dub5.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/playbook-dub5.yml"
    end
  end
end
