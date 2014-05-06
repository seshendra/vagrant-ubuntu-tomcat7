# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.network :private_network, ip: '192.168.33.10'
  config.vm.network :forwarded_port, guest: 8080, host: 4880
  config.vm.network :forwarded_port, guest: 8000, host: 4800
  config.vm.network :forwarded_port, guest: 1099, host: 1099
  config.vm.synced_folder "/tmp/artifacts", "/tmp/artifacts", create: true
  config.vm.provision :puppet, :module_path => "manifests/modules" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "default.pp"
  end
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
end
