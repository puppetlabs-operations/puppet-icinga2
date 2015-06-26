# == Class: icinga2::server::install
#
# This class installs the server components for the Icinga 2 monitoring system.
#
# === Parameters
#
# Coming soon...
#
# === Examples
#
# Coming soon...
#

class icinga2::server::install inherits icinga2::server {

  include icinga2::server
  #Apply our classes in the right order. Use the squiggly arrows (~>) to ensure that the
  #class left is applied before the class on the right and that it also refreshes the
  #class on the right.
  #
  #Here, we're setting up the package repos first, then installing the packages:
  class{'icinga2::server::repos':} ~>
  class{'icinga2::server::install::packages':} ~>
  class{'icinga2::server::install::execs':} ->
  Class['icinga2::server::install']

  include icinga2::server::repos
#Install packages for Icinga 2:
class icinga2::server::install::packages inherits icinga2::server {

  include icinga2::server

  #Install the Icinga 2 package
  package {$icinga2_server_package:
    ensure   => installed,
    provider => $package_provider,
  }

  if $server_install_nagios_plugins == true {
    #Install the Nagios plugins packages:
    package {$icinga2_server_plugin_packages:
      ensure          => installed,
      provider        => $package_provider,
      install_options => $server_plugin_package_install_options,
    }
  }

  if $install_mail_utils_package == true {
    #Install the package that has the 'mail' binary in it so we can send notifications:
    package {$icinga2_server_mail_package:
      ensure          => installed,
      provider        => $package_provider,
      install_options => $server_plugin_package_install_options,
    }
  }

  #Pick the right DB lib package name based on the database type the user selected:
  case $server_db_type {
    #MySQL:
    'mysql': { $icinga2_server_db_connector_package = 'icinga2-ido-mysql'}
    #Postgres:
    'pgsql': { $icinga2_server_db_connector_package = 'icinga2-ido-pgsql'}
    default: { fail("${icinga2::params::server_db_type} is not a supported database! Please specify either 'mysql' for MySQL or 'pgsql' for Postgres.") }
  }

  #Install the IDO database connector package. See:
  #http://docs.icinga.org/icinga2/latest/doc/module/icinga2/toc#!/icinga2/latest/doc/module/icinga2/chapter/getting-started#configuring-db-ido
  package {$icinga2_server_db_connector_package:
    ensure   => installed,
    provider => $package_provider,
  }

}

#This class contains exec resources
class icinga2::server::install::execs inherits icinga2::server {

  include icinga2::server

  #Configure database schemas and IDO modules
  case $server_db_type {
    'mysql': {
     #Enable the MySQL IDO module:
      exec { 'mysql_module_enable':
        user    => 'root',
        path    => '/usr/bin:/usr/sbin:/bin/:/sbin',
        command => '/usr/sbin/icinga2 enable feature ido-mysql && touch /etc/icinga2/mysql_module_loaded.txt',
        creates => '/etc/icinga2/mysql_module_loaded.txt',
      }
    }

    'pgsql': {
      #Load the Postgres DB schema:
      #Enable the Postgres IDO module:
      exec { 'postgres_module_enable':
        user    => 'root',
        path    => '/usr/bin:/usr/sbin:/bin/:/sbin',
        command => '/usr/sbin/icinga2 enable feature ido-pgsql && touch /etc/icinga2/postgres_module_loaded.txt',
        creates => '/etc/icinga2/postgres_module_loaded.txt',
      }
    }

    default: { fail("${server_db_type} is not supported!") }
  }
}
