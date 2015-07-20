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
  include icinga2::params
  #Apply our classes in the right order. Use the squiggly arrows (~>) to ensure that the
  #class left is applied before the class on the right and that it also refreshes the
  #class on the right.
  #
  #Here, we're setting up the package repos first, then installing the packages:

  #Install the Icinga 2 package
  package {$icinga2_server_package:
    ensure   => installed,
    provider => $package_provider,
  }

  include icinga2::db::packages

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
}
