class dse_cassandra::oracle_java($java_distrib = 'jre', $java_version='6u37', $java_prefix = '/usr/lib/jvm') {
  $arch = $::architecture ? {
    'amd64' => 'x64',
    default => 'i586',
  }

  $package_name = "${java_distrib}-${java_version}-linux-${arch}.tar.gz"
  
  file { "${java_prefix}":
    ensure => directory,
  }
  
  file { "${java_prefix}/${package_name}":
    ensure  => present,
    source  => "puppet:///modules/dse_cassandra/${package_name}",
    require => File["${java_prefix}"],
    notify  => Exec['unpack-java'],
  }

  exec { 'unpack-java':
    command     => "/bin/tar zxf ${package_name}",
    cwd         => "${java_prefix}",
    refreshonly => true,
    notify      => [Exec['rename-java-dir'], Exec['update-alternatives-java']],
  }
  
  exec { 'rename-java-dir':
    command     => "mv jre1.* ${java_version}",
    cwd         => "${java_prefix}",
    path        => '/bin',
    refreshonly => true,
  }
  
  exec { 'update-alternatives-java':
    command   =>  "update-alternatives --install '/usr/bin/java' 'java' '/usr/lib/jvm/${java_version}/bin/java' 1",
    path   => ['/bin', '/usr/bin', '/usr/sbin', '/sbin'],
    notify    => File['/etc/alternatives/java'],
    unless    => "update-alternatives --display java | grep ${java_version}",
  }
  
  file { '/etc/alternatives/java':
    ensure => 'link',
    target => "/usr/lib/jvm/${java_version}/bin/java",
  } 
}
