class dse_cassandra($version = '2.2.1-1') {
  class { 'dse_cassandra::oracle_java': }

  apt::source { 'datastax':
    location      => 'http://vsukyas_reachlocal.com:Yuj02tkFtnTE5zD@debian.datastax.com/enterprise',
    release       => 'stable',
    repos         => 'main',
  }

  apt::key { 'datastax':
    key           => 'B999A372',
    key_source    => 'http://debian.datastax.com/debian/repo_key',
  }

  $packages = [ 'dse-full', 'dse', 'dse-hive', 'dse-pig', 'dse-demos', 'dse-libsolr', 'dse-libtomcat', 'dse-libsqoop', 'dse-liblog4j', 'dse-libmahout', 'dse-libhive', 'dse-libcassandra', 'dse-libpig', 'dse-libhadoop' ]

  package { $packages:
    ensure        => $version,
  }

  exec { 'update-alternatives-oracle-java':
    command => "update-alternatives --set java /usr/lib/jvm/6u37/bin/java",
    path   => ['/bin', '/usr/bin', '/usr/sbin', '/sbin'],
  }

  service {'dse':
    ensure => 'running',
  }

  Class['dse_cassandra::oracle_java'] -> Exec['update-alternatives-oracle-java'] -> Apt::Source["datastax"] ->
  Apt::Key["datastax"] -> Package['dse-libtomcat'] -> Package['dse-libsolr'] -> 
  Package['dse-libsqoop'] -> Package['dse-liblog4j'] ->
  Package['dse-libmahout'] -> Package['dse-libhive'] ->
  Package['dse-libcassandra'] -> Package['dse-libpig'] ->
  Package['dse-libhadoop'] -> Package['dse'] -> 
  Package['dse-hive'] -> Package['dse-pig'] ->
  Package['dse-demos'] -> Package['dse-full'] -> Service["dse"]
}
