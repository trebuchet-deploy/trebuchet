# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

dir = File.expand_path File.dirname(__FILE__)
config = YAML.load_file(File.join(dir, 'vagrant', 'config.yml'))

share_options = {}

if config['use_nfs']
    share_options[:type] = :nfs
    share_options[:mount_options] = ['noatime','rsize=32767','wsize=32767','async']
end

Vagrant.configure(2) do |config|
    config.vm.provider :virtualbox do |v|
        v.memory = 1024
    end

    config.vm.define "deploy" do |deploy|
        deploy.vm.synced_folder "vagrant/salt_root", "/srv/salt", share_options

        deploy.vm.box = "ubuntu/trusty64"
        deploy.vm.host_name = "deploy"
        deploy.vm.network :private_network, ip: "10.10.10.2"
        deploy.vm.provision :salt do |salt|
            salt.install_master = true
            salt.run_highstate = true

            salt.master_key = "vagrant/master/master.pem"
            salt.master_pub = "vagrant/master/master.pub"
            salt.master_config = "vagrant/master/master.conf"

            salt.seed_master = {
                'deploy' => "vagrant/master/minion.pub",
                'target' => "vagrant/minion/minion.pub",
            }

            salt.minion_key = "vagrant/master/minion.pem"
            salt.minion_pub = "vagrant/master/minion.pub"
            salt.minion_config = "vagrant/minion/minion.conf"

        end
    end

    config.vm.define "target" do |target|
        target.vm.box = "ubuntu/trusty64"
        target.vm.host_name = "target"
        target.vm.network :private_network, ip: "10.10.10.3"

        target.vm.provision :salt do |salt|
            salt.install_master = false
            salt.run_highstate = true

            salt.minion_config = "vagrant/minion/minion.conf"
            salt.minion_key = "vagrant/minion/minion.pem"
            salt.minion_pub = "vagrant/minion/minion.pub"
        end
    end
end
