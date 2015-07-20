class icinga2::db::packages {
  require icinga2
  #Install the IDO database connector package. See:
  #http://docs.icinga.org/icinga2/latest/doc/module/icinga2/toc#!/icinga2/latest/doc/module/icinga2/chapter/getting-started#configuring-db-ido
  package {$icinga2::icinga2_server_db_connector_package:
    ensure   => installed,
    provider => $icinga2::params::package_provider,
  }
}
