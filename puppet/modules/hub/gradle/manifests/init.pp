class gradle(
  $version  = 'UNSET',
  $base_url = 'UNSET',
  $url      = 'UNSET',
  $target   = 'UNSET',
  $timeout  = 120,
  $daemon   = true
) {

  include gradle::params

  $version_real = $version ? {
    'UNSET' => $::gradle::params::version,
    default => $version,
  }

  $base_url_real = $base_url ? {
    'UNSET' => $::gradle::params::base_url,
    default => $base_url,
  }

  $url_real = $url ? {
    'UNSET' => "${base_url_real}/gradle-${version_real}-all.zip",
    default => $url,
  }

  $target_real = $target ? {
    'UNSET' => $::gradle::params::target,
    default => $target,
  }

  exec { 
    "get-gradle-${version_real}-all.zip" :
      command => "wget -N https://services.gradle.org/distributions/gradle-${version_real}-all.zip --no-check-certificate",
      path    => "/usr/local/bin:/bin:/usr/bin",
      notify  => Exec["unzip-gradle"],
      timeout => 1800;

    'unzip-gradle':
      command => "unzip -oq gradle-${version_real}-all.zip -d /opt/gradle",
      cwd     => '/home/ariba/',
      path    => "/usr/local/bin:/bin:/usr/bin",
      user    => 'root',
      notify  => Exec["link-gradle"];

    'link-gradle':
      command => "ln -sfnv gradle-${version_real} /opt/gradle/latest",
      cwd     => '/opt/gradle/',
      path    => "/usr/local/bin:/bin:/usr/bin",
      user    => 'root',
      notify  => File["/etc/profile.d/gradle.sh"];
  }

  file { 
    '/etc/profile.d/gradle.sh':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      content => template("${module_name}/gradle.sh");
  }

}