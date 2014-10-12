#
class solr (
  $version   = '3.6.2',
  $corecount = 4,
  $urlprefix = 'https://archive.apache.org/dist/lucene/solr',
) {
  # @todo: make these parameters of this class:
  $solr_user = 'solr'
  $solr_home = '/opt/solr'

  #             http://mirror.mel.bkb.net.au/pub/apache/lucene/solr/3.6.1/apache-solr-3.6.1.tgz
  $appname   = 'apache-solr'
  $tarname   = "apache-solr-${version}.tgz"


  # This is where the core directory names come from - from this inline template
  $cores_str = inline_template("<%= (1 .. corecount.to_i).collect{|x| 'core'+x.to_s+','}  %>")
  # inline_template cannot return an array, it returns string which we need to split into an array:
  $cores = split($cores_str, ',')


  # this variable is used in the password related erb files:
  $user_pass = generate_usrpass($corecount)


  # include java
  # now temporarily (@todo):
  package { 'openjdk-7-jre-headless': ensure => installed }

  exec { 'get-solr-tar':
    command   => "/usr/bin/wget ${urlprefix}/${version}/${tarname} -O /tmp/${tarname}",
  # logoutput => on_failure,
    logoutput => true,
    unless    => "/usr/bin/test -d ${solr_home}",
  # require   => [ Package["wget"] ];
  }

  exec { 'untar':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "tar -xzf /tmp/${tarname} -C ${solr_home} --no-same-owner --strip-components=2 ${appname}-${version}/example",
    user    => 'root', # we want this content of the tar to be owned by root - see --no-same-owner above
    onlyif  => "test `ls -1A ${solr_home} | wc -l` -eq 0",
    require => [ Exec['get-solr-tar'], File[$solr_home] ],
  }

  file { $solr_home:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Exec['get-solr-tar'],
  }
  file { [ "${solr_home}/logs",
           "${solr_home}/solr",
           "${solr_home}/work" ]:
    ensure  => 'directory',
    owner   => 'solr',
    group   => 'root',
    mode    => '0755',
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }

  user { $solr_user:
    home       => $solr_home,
    shell      => '/bin/false',
    gid        => $solr_user,
    managehome => 'false', # we have root permissions on home
    system     => 'true',
    require    => [ Group[$solr_user], File[$solr_home] ],
  }
  group { $solr_user:
    ensure => 'present',
    system => 'true',
  }

  $confdir="${solr_home}/solr/conf"

  file{ "${solr_home}/solr/conf":
    ensure  => directory,
    recurse => true,
    replace => true,
    purge   => true,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/solr/solr-conf/solr-3.x',
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }


  file { "${solr_home}/solr/solr.xml":
    ensure  => present,
    content => template('solr/solr.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  define make_core {
    file { "${solr::solr_home}/solr/${name}":
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755'
    }
    file { "${solr::solr_home}/solr/${name}/data":
      ensure => directory,
      owner  => 'solr',
      group  => 'solr',
      mode   => '0755'
    }
    file { "${solr::solr_home}/solr/${name}/conf":
      ensure => link,
      target => "${solr::solr_home}/solr/conf",
    }
  }


  # make the core directories (passing an array with core names):
  make_core { $cores:
    notify => Service['jetty6'],
  }

  file { '/etc/init.d/jetty6':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    source  => 'puppet:///modules/solr/init.d-jetty6.sh',
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }
  file { '/etc/default/jetty':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('solr/default-jetty.erb'),
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }

  file { "${solr_home}/etc/jetty-logging.xml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/solr/jetty-logging.xml',
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }

  file { "${solr_home}/etc/webdefault.xml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('solr/webdefault.xml.erb'),
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }

  file { "${solr_home}/etc/jetty.xml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('solr/jetty.xml.erb'),
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }

  file { "${solr_home}/etc/realm.properties":
    ensure  => present,
    content => template('solr/realm.properties.erb'),
    owner   => 'root',
    group   => 'solr',
    mode    => '0640',
    require => Exec['untar'],
    notify  => Service['jetty6'],
  }

  file { '/root/solr_pass.txt':
    ensure  => present,
    content => template('solr/solr_pass.txt.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  service { 'jetty6':
    enable  => true,
    ensure  => running,
  }
}
