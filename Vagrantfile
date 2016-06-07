# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
settings = YAML.load_file File.join(File.dirname(__FILE__), "puppet/hieradata/common.yaml")

selenium_version = settings['selenium_version']

Vagrant.configure("2") do |config|

  config.vm.box = settings['host_box'] || "pws/centos65"
  config.ssh.username = settings['ariba_user']

  config.vm.define "db" do |db|
    db.vm.hostname = settings['db_hostname']
    db.vm.network "private_network", ip: settings['host_db_address']

    db.vm.synced_folder "dump/", "/dump"

    db.vm.provider "vmware_fusion" do |vm|
      vm.vmx["memsize"] = "3072"
    end

    db.vm.provider "vmware_workstation" do |vm|
      vm.vmx["memsize"] = "3072"
    end

    db.vm.provider "virtualbox" do |vb|
      vb.memory = "3072"
    end

    db.vm.provision "shell", path: "puppet/script/install-puppet-modules-db.sh"
    db.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "base-db.pp"
      puppet.module_path = "puppet/modules/db"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.options = "--verbose --debug"
    end
    db.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime", :run => 'always'
  end

  config.vm.define "app", primary: true do |app|
    app.vm.hostname = settings['ariba_hostname']
    app.vm.network "private_network", ip: settings['host_app_address']
    app.vm.synced_folder "puppet/install_ariba", "/home/ariba/install_sources"

    app.ssh.forward_agent = true
    app.ssh.forward_x11 = true

    app.vm.provider "vmware_fusion" do |vm|
      vm.vmx["memsize"] = "4096"
    end

    app.vm.provider "vmware_workstation" do |vm|
      vm.vmx["memsize"] = "4096"
    end

    app.vm.provider "virtualbox" do |vb|
      vb.memory = "3072"
    end

    app.vm.provision "shell", path: "puppet/script/install-puppet-modules-app.sh"
    app.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "base-app.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.options = "--verbose --debug"
    end
    app.vm.provision "shell", path: "puppet/script/run-ariba-app.sh", privileged: false, run: 'always'
    app.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime", :run => 'always'
  end

  config.vm.define "win_10" do |win10|
    win10.vm.box = "windows_10"
    
    win10.vm.synced_folder "puppet/install_ariba/test", "/test"

    win10.vm.provision "shell", path: "puppet/install_ariba/test/install_win_jdk.ps1"
    win10.vm.provision "shell", path: "puppet/install_ariba/test/install_browsers.ps1"

    win10.vm.provision "shell", path: "puppet/install_ariba/test/start_win_selenium.bat", run: 'always', args: ["#{selenium_version}", settings['host_hub_address']]
    #win10.vm.provision "shell", path: "vagrant-shell.ps1", run: 'always'
    #win10.vm.provision "shell", inline: "Start-Job { & java -jar C:\\test\\selenium-server-standalone-2.50.1.jar -role node -port 6666 -hub http://192.168.90.53:4444/grid/register/ -browser browserName=\"firefox\" }", run: 'always'
    #win10.vm.provision "shell", inline: "java -jar C:\\test\\selenium-server-standalone-2.50.1.jar -role node -port 6666 -hub http://192.168.90.53:4444/grid/register/ -browser browserName=\"firefox\"", run: 'always'
    #win10.vm.provision "shell", inline: "Start-Job -scriptblock { java -jar C:\\test\\selenium-server-standalone-2.50.1.jar -role node -port 6666 -hub http://192.168.90.53:4444/grid/register/ -browser browserName=\"firefox\" }", run: 'always'
  end

  config.vm.define "hub" do |hub|
    hub.vm.hostname = settings['hub_hostname']
    hub.vm.network "private_network", ip: settings['host_hub_address']

    hub.vm.provider "vmware_fusion" do |vm|
      vm.vmx["memsize"] = "1024"
    end

    hub.vm.provider "vmware_workstation" do |vm|
      vm.vmx["memsize"] = "1024"
    end

    hub.vm.provider "virtualbox" do |vb|
      vb.memory = "3072"
    end

    hub.vm.synced_folder "puppet/install_ariba/test", "/test"

    hub.vm.provision "shell", path: "puppet/script/install-puppet-modules-hub.sh"
    hub.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "base-hub.pp"
      puppet.module_path = "puppet/modules/hub"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.options = "--verbose --debug"
    end
    hub.vm.provision "shell", path: "puppet/script/run-test.sh", privileged: false, run: 'always', args: "#{selenium_version}"
    hub.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime", :run => 'always'
  end
end
