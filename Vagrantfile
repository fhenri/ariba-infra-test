# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
settings = YAML.load_file 'puppet/hieradata/common.yaml'

Vagrant.configure("2") do |config|

  config.vm.box = settings['host_box'] || "pws/centos65"
  config.ssh.username = settings['ariba_user']

  config.vm.define "db" do |db|
    db.vm.hostname = settings['db_hostname']
    db.vm.network "private_network", ip: settings['host_db_address']

    db.vm.provider "vmware_fusion" do |vm|
      vm.vmx["memsize"] = "3072"
    end

    db.vm.provision "shell", path: "puppet/script/install-puppet-modules-db.sh"
    db.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "base-db.pp"
      puppet.module_path = "puppet/modules/db"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.options = "--verbose --debug"
    end
  end

  config.vm.define "app", primary: true do |app|
    app.vm.hostname = settings['ariba_hostname']
    app.vm.network "private_network", ip: settings['host_app_address']
    app.vm.synced_folder "puppet/install_ariba", "/home/ariba/install_sources"
    app.vm.synced_folder "./", "/home/ariba/project"

    app.ssh.forward_agent = true
    app.ssh.forward_x11 = true

    app.vm.provider "vmware_fusion" do |vm|
      # Don't boot with headless mode
      #vm.gui = true
   
      vm.vmx["memsize"] = "4096"
    end

    app.vm.provision "shell", path: "puppet/script/install-puppet-modules-app.sh"
    app.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "base-app.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.options = "--verbose --debug"
    end
  end

  config.vm.define "hub" do |hub|
    hub.vm.hostname = settings['hub_hostname']
    hub.vm.network "private_network", ip: settings['host_hub_address']

    hub.vm.provider "vmware_fusion" do |vm|
      vm.vmx["memsize"] = "1024"
    end

    hub.vm.provision "shell", path: "puppet/script/install-puppet-modules-hub.sh"
    hub.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "base-hub.pp"
      puppet.module_path = "puppet/modules/hub"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.options = "--verbose --debug"
    end
  end

  config.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime", :run => 'always'
end
