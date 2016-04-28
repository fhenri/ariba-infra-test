Package {
  allow_virtual => true,
}

class { 'apache': }

#necessary for ariba installation from command line
class { 'perl': }

class { 'java' : 
  distribution  => 'jdk',
  package       => 'java-1.6.0-openjdk-devel'
}

# ant comes as package from ariba install with version 1.7
# dependencies install java 1.6 so java 1.8 is installed after ariba as part 
# of another package
#class { 'ant':
#  version => '1.9.6',
#}

class ariba {
  require perl
  require java

  $ARIBA_HOST     = hiera('ariba_hostname')
  $ARIBA_DB_HOST  = hiera('db_hostname')
  $ARIBA_DB_IP    = hiera('host_db_address')
  $ARIBA_VERSION  = hiera('ariba_version')
  $ARIBA_SP       = hiera('ariba_sp')
  $ARIBA_USER     = hiera('ariba_user')

  $ARIBA_ROOT        = "/home/$ARIBA_USER"
  $ARIBA_INST        = "$ARIBA_ROOT/install_sources"
  $ARIBA_CONF        = "$ARIBA_INST/conf"
  $ARIBA_BASE        = "$ARIBA_ROOT/Sourcing"

  $AES_INST_PROPS    = "$ARIBA_INST/Upstream-$ARIBA_VERSION"

  package {
    ['libXext.i686', 'glibc.i686' , 'dejavu*', 
     'unixODBC', 'Xvfb', 'lsof', 
     'mutt', 'ant', 'git']:
      ensure => installed;
  }

  user { 
    $ARIBA_USER:
      ensure  => present,
      shell   => '/bin/bash'
  }

  File {
    ensure  => 'file',
    owner   => $ARIBA_USER,
  }

  # check if we have a weblogic-defaultconfig.xml - used for multi node configuration
  # default ariba setup takes 2 nodes
  $weblogic_node = file("$ARIBA_INST/properties/weblogic-defaultconfig.xml",'/dev/null')
  if($weblogic_node != '') {
      file { "$ARIBA_CONF/weblogic-defaultconfig.xml":
        source  => "$ARIBA_INST/properties/weblogic-defaultconfig.xml",
        notify  => Exec['install_ariba'];
      }
  }

  file {
    "$ARIBA_ROOT":
      ensure => "directory",
      mode   => 0701; 

    "$ARIBA_CONF":
      ensure => "directory";

    "$ARIBA_CONF/wl-1036-silent.xml":
      source  => "$ARIBA_INST/properties/wl-1036-silent.xml";

    "$ARIBA_CONF/script.table":
      require => File["$ARIBA_CONF"],
      source  => "$ARIBA_INST/properties/script.table";

    "$ARIBA_CONF/ParametersFix.table.merge":
      require => File["$ARIBA_CONF"],
      content => template("$ARIBA_INST/properties/Parameters.table.merge.erb");

    "$ARIBA_CONF/sp-upstream-installer.properties":
      require => File["$ARIBA_CONF"],
      content => template("$ARIBA_INST/properties/sp-upstream-installer.properties.erb");

    "$ARIBA_CONF/upstream-installer.properties":
      require => File["$ARIBA_CONF"],
      content => template("$ARIBA_INST/properties/upstream-installer.properties.erb");

    "/etc":
      ensure  => 'directory',
      source  => "$ARIBA_INST/etc",
      recurse => 'remote',
      purge   => true,
      replace => "no",
      owner   => 'root',
      mode    => 0755;

    "/etc/httpd/conf.d/ariba.conf":
      mode    => 0777,
      owner   => root,
      content => template("$ARIBA_INST/properties/ariba.conf.erb");

    "$ARIBA_ROOT/.ssh/config":
      mode    => 0600,
      source  => "$ARIBA_INST/ssh/config";

    "$ARIBA_ROOT/.ssh/id_rsa":
      mode    => 0600,
      source  => "$ARIBA_INST/ssh/id_rsa";
  }

  file_line { 
    'authorized_keys':
       path => '/home/ariba/.ssh/authorized_keys',
       line => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6rbHB03+zVZ8GHCiYwWL1a4+1bOnvKPqEcI3mXOQc7RXlUo8oi/xHe1K/FPpqC+NFea9rqzwdgiCWnVKVxykt9xvN4XJeSroOTk66on7Ss5ZYXLhkSo0/RakfZ3dmXjLoUk7xZmsSQZdwkPQeb7M6nJf+T3VGKwahK5coaAIt8QD1AOfMn3rWwy5bzHi0+yTkB3WMFGhfUTINuKw8adRajLiNUB8qUEfjT6or8N39CYTtsEY3twgvy0+I6Uo30z5fqIaBTKerJZ/6B5rjmIck69rGzhue9eb+fbEZmULjQa5VWjNKut5qJ2FLpAFi8BsekDaYmJowXz79DK4eZfAx powersource-key',
  }

  exec {
    "install_weblogic" :
      environment => ["INSTALL_DIR=$ARIBA_INST"],
      command => "$ARIBA_INST/install-ariba.sh wl.",
      cwd     => "$ARIBA_INST",
      timeout => 0,
      returns => [0, 1],
      require => File["$ARIBA_ROOT", "$ARIBA_CONF/wl-1036-silent.xml"],
      #onlyif => "/sbin/swapon -s | /bin/grep file > /dev/null",
      user    => "$ARIBA_USER";

    "autostart_xvfb":  
      command => "/sbin/chkconfig --level 2345 ariba-Xvfb on",
      user    => root,
      require =>File['/etc'];

    "install_ariba" :
      environment => ["INSTALL_DIR=$ARIBA_INST"],
      command => "$ARIBA_INST/install-ariba.sh aes. $ARIBA_VERSION $ARIBA_SP",
      cwd     => "$ARIBA_INST",
      timeout => 0,
      returns => [0, 1],
      require => [
        Exec['install_weblogic', 'autostart_xvfb'],
        File[
          "$ARIBA_CONF/sp-upstream-installer.properties",
          "$ARIBA_CONF/upstream-installer.properties",
          "$ARIBA_CONF/script.table",
          "$ARIBA_CONF/ParametersFix.table.merge"
        ]
      ],
      creates => "$ARIBA_BASE",
      user    => "$ARIBA_USER";

    "autostart_nodemanager":  
      command => "/sbin/chkconfig --level 2345 ariba-NodeManager on",
      user => root,
      require=>[Exec['install_ariba'], File['/etc']];

    "autostart_weblogic":  
      command => "/sbin/chkconfig --level 2345 ariba-Weblogic on",
      user => root,
      require=>[Exec['install_ariba'], File['/etc']];
  }

  ## clean files so we can rerun the install
  $files = [
      "$ARIBA_CONF/wl-1036-silent.xml",
      "$ARIBA_CONF/sp-upstream-installer.properties",
      "$ARIBA_CONF/upstream-installer.properties",
      "$ARIBA_CONF/upstream-installer.properties.orig",
      "$ARIBA_CONF/script.table",
    ]

  ## using file / absent does not work as it will be reduplicate declaration
  #file { $files:
  #  ensure  => absent,
  #  require => [Exec['install_ariba'], File['/etc']];
  #}
  define cleanfile {
    exec { "rm ${name}":
      path    => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }
  }
  cleanfile { $files: 
      require => [Exec['install_ariba']];
  }
}

include apache
include perl
include ariba
include java
