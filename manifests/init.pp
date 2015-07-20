class icinga2(
  $use_debmon_repo = false,
  $server_db_type = $icinga2::params::server_db_type,
){

  #Pick the right DB lib package name based on the database type the user selected:
  case $server_db_type {
    #MySQL:
    'mysql': { $icinga2_server_db_connector_package = 'icinga2-ido-mysql'}
    #Postgres:
    'pgsql': { $icinga2_server_db_connector_package = 'icinga2-ido-pgsql'}
    default: { fail("${icinga2::params::server_db_type} is not a supported database! Please specify either 'mysql' for MySQL or 'pgsql' for Postgres.") }
  }


  if $use_debmon_repo != false {
    include icinga2::repos
  }
}
