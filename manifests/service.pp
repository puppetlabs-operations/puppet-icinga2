# == Class: icinga2::service
#
# This class manages the Icinga 2 daemon.
#
class icinga2::service {
  exec { 'icinga2 daemon config test':
    command => 'icinga2 daemon -C',
    path    => $::path,
    onlyif  => "test ! -e '${::icinga2::pid_file}'",
  } ~>

  service { 'icinga2':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    restart    => $::icinga2::restart_cmd,
  }
}

