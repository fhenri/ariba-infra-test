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

    "/home/ariba/.ssh/config":
      mode    => 0600,
      source  => "/vagrant/puppet/install_ariba/ssh/config";

    "/home/ariba/.ssh/id_rsa":
      mode    => 0600,
      source  => "/vagrant/puppet/install_ariba/ssh/id_rsa";
  } 

  file_line { 
    'authorized_keys':
       path => '/home/ariba/.ssh/authorized_keys',
       line => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6rbHB03+zVZ8GHCiYwWL1a4+1bOnvKPqEcI3mXOQc7RXlUo8oi/xHe1K/FPpqC+NFea9rqzwdgiCWnVKVxykt9xvN4XJeSroOTk66on7Ss5ZYXLhkSo0/RakfZ3dmXjLoUk7xZmsSQZdwkPQeb7M6nJf+T3VGKwahK5coaAIt8QD1AOfMn3rWwy5bzHi0+yTkB3WMFGhfUTINuKw8adRajLiNUB8qUEfjT6or8N39CYTtsEY3twgvy0+I6Uo30z5fqIaBTKerJZ/6B5rjmIck69rGzhue9eb+fbEZmULjQa5VWjNKut5qJ2FLpAFi8BsekDaYmJowXz79DK4eZfAx powersource-key',
  }

  class { 'gradle':
    version => '2.2',
    require => Package["unzip"],
  }
}

include java
include tools_install