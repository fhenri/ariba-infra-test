Package {
  allow_virtual => true,
}

class { 'java' : 
    distribution          => 'jdk',
    package               => 'java-1.8.0-openjdk-devel',
    java_alternative      => 'java-1.8.0',
    java_alternative_path => '/usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java'
}
  
class tools_install {
  require java

  package {
    ['unzip', 'git']:
      ensure => installed;
  }

  file {
    "/home/ariba/selenium-server-standalone-2.50.1.jar":
      ensure  => "file",
      mode    => 0755,
      owner   => ariba,
      source  => "/vagrant/puppet/install_ariba/test/selenium-server-standalone-2.50.1.jar";
  } 

  class { 'gradle':
    version => '2.2',
    require => Package["unzip"],
  }
}

include java
include tools_install