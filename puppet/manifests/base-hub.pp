Package {
  allow_virtual => true,
}

class { 'java' : 
    distribution          => 'jdk',
    package               => 'java-1.8.0-openjdk-devel',
    java_alternative      => 'java-1.8.0',
    java_alternative_path => '/usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java'
}
  
class gradle_install {
  require java

  package {
    ['unzip', 'git']:
      ensure => installed;
  }

  class { 'gradle':
    version => '2.2',
    require => Package["unzip"],
  }
}

include java
include gradle_install