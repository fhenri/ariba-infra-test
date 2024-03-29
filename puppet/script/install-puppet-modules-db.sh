#!/bin/bash
yum -y update ca-certificates
cp -fr /etc/pki/tls/certs/ca-bundle.crt.rpmnew /etc/pki/tls/certs/ca-bundle.crt
mkdir -p /etc/puppet/modules;

if [ ! -d /etc/puppet/modules/puppetlabs-java ]; then
  puppet module install puppetlabs-java --version 1.4.1
fi
