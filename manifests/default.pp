class java-development-env {
  include apt
  include maven

  apt::ppa { "ppa:webupd8team/java": }

  # Set current Tomcat download url.
  $tomcat_url = "http://apache.mirrors.pair.com/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54.tar.gz"

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
  }

  # install necessary ubuntu packages to setup the environment
  package { ["vim",
             "curl",
             "git-core",
             "expect",
             "bash"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  package { ["oracle-java7-installer"]:
    ensure => present,
    require => Exec["apt-get update 2"],
  }

  exec {
    "accept_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/vagrant",
    user => "vagrant",
    path    => "/usr/bin/:/bin/",
    require => Package["curl"],
    before => Package["oracle-java7-installer"],
    logoutput => true,
  }

  $server = {
    id => "remote-tomcat-server",
    username => "admin",
    password => "tomcat",
  }

  maven::settings { 'mvn-settings' :
    local_repo => '/vagrant/maven/.m2/repository',
    servers    => [$server],
  }

  Exec {
    path  => "${::path}",
  }

  group { "puppet":
    ensure  => present,
  }

  package { "acpid":
    ensure  => installed,
  }

  package { "supervisor":
    ensure  => installed,
  }

  package { "wget":
    ensure  => installed,
  }

  user { "vagrant":
    ensure    => present,
    comment   => "Tomcat User",
    home      => "/home/vagrant",
    shell     => "/bin/bash",
  }

  exec { "check_tomcat_url":
    cwd       => "/tmp",
    command   => "wget -S --spider ${tomcat_url}",
    timeout   => 900,
    require   => Package["wget"],
    notify    => Exec["get_tomcat"],
    logoutput => "on_failure"
  }

  exec { "get_tomcat":
    cwd       => "/tmp",
    command   => "wget ${tomcat_url} -O tomcat.tar.gz > /opt/.tomcat_get_tomcat",
    creates   => "/opt/.tomcat_get_tomcat",
    timeout   => 900,
    require   => Package["wget"],
    notify    => Exec["extract_tomcat"],
    logoutput => "on_failure"
  }

  exec { "extract_tomcat":
    cwd         => "/vagrant",
    command     => "tar zxf /tmp/tomcat.tar.gz ; mv apache* tomcat",
    creates     => "/vagrant/tomcat",
    require     => Exec["get_tomcat"],
    refreshonly => true,
  }

  file { "/vagrant/tomcat/conf/tomcat-users.xml":
    ensure    => present,
    content   => "<?xml version='1.0' encoding='utf-8'?>
  <tomcat-users>
    <role rolename=\"manager-gui\" />
    <role rolename=\"manager-script\" />
    <role rolename=\"manager-jmx\" />
    <role rolename=\"manager-status\" />
    <user username=\"admin\" password=\"tomcat\" roles=\"manager-gui, manager-script, manager-jmx, manager-status\"/>
  </tomcat-users>",
    require   => Exec["extract_tomcat"],
  }

  file { "/vagrant/tomcat":
    ensure    => directory,
    owner     => "vagrant",
    mode      => 0755,
    recurse   => true,
    require   => Exec["extract_tomcat"],
  }

  file { "/vagrant/tomcat/bin/setenv.sh":
    ensure    => present,
    owner     => "vagrant",
    mode      => 0755,
    content   => '#!/bin/sh
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=192.168.33.10"
export CATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n"
echo "Using CATALINA_OPTS:"
for arg in $CATALINA_OPTS
do
    echo ">> " $arg
done
echo ""',
    require   => Exec["extract_tomcat"],
  }

  file { "/etc/supervisor/conf.d/tomcat.conf":
    ensure    => present,
    content   => "[program:tomcat]
command=/vagrant/tomcat/bin/catalina.sh run
directory=/vagrant/tomcat/bin
autostart=no
user=vagrant
stopsignal=QUIT",
    require   => [ Package["supervisor"], File["/vagrant/tomcat/conf/tomcat-users.xml"] ],
    notify    => Exec["update_supervisor"],
  }

  exec { "update_supervisor":
    command     => "supervisorctl update",
    refreshonly => true,
  }

}

include java-development-env
