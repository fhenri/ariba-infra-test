#!/bin/bash
yum -y update ca-certificates
cp -fr /etc/pki/tls/certs/ca-bundle.crt.rpmnew /etc/pki/tls/certs/ca-bundle.crt
mkdir -p /etc/puppet/modules;

if [ ! -d /etc/puppet/modules/example42-perl ]; then
  puppet module install example42-perl --version 2.0.20
fi

if [ ! -d /etc/puppet/modules/puppetlabs-apache ]; then
  puppet module install puppetlabs-apache --version 1.5.0
fi

if [ ! -d /etc/puppet/modules/puppetlabs-java ]; then
  puppet module install puppetlabs-java --version 1.4.1
fi
