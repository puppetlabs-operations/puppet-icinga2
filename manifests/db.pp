class icinga2::db(
  $server_db_type = $icinga2::server_db_type,
  $db_host = undef,
  $db_name = undef,
  $db_user = undef,
  $db_password = undef,
){

  include icinga2::params
  case $::operatingsystem {
    'CentOS','RedHat': {
      #...and database that the user picks
      case $server_db_type {
        'mysql': { $server_db_schema_path = '/usr/share/icinga2-ido-mysql/schema/mysql.sql' }
        'pgsql': { $server_db_schema_path = '/usr/share/icinga2-ido-pgsql/schema/pgsql.sql' }
        default: { fail("${server_db_type} is not a supported database! Please specify either 'mysql' for MySQL or 'pgsql' for Postgres.") }
      }
    }

    #Ubuntu systems:
    'Ubuntu': {
      #Pick set the right path where we can find the DB schema
      case $server_db_type {
        'mysql': { $server_db_schema_path = '/usr/share/icinga2-ido-mysql/schema/mysql.sql' }
        'pgsql': { $server_db_schema_path = '/usr/share/icinga2-ido-pgsql/schema/pgsql.sql' }
        default: { fail("${server_db_type} is not a supported database! Please specify either 'mysql' for MySQL or 'pgsql' for Postgres.") }
      }
    }

    #Debian systems:
    'Debian': {
      #Pick set the right path where we can find the DB schema
      case $server_db_type {
        'mysql': { $server_db_schema_path = '/usr/share/icinga2-ido-mysql/schema/mysql.sql' }
        'pgsql': { $server_db_schema_path = '/usr/share/icinga2-ido-pgsql/schema/pgsql.sql' }
        default: { fail("${server_db_type} is not a supported database! Please specify either 'mysql' for MySQL or 'pgsql' for Postgres.") }
      }
    }

    #Fail if we're on any other OS:
    default: { fail("${::operatingsystem} is not supported!") }
  }
  case $server_db_type {
    'mysql': {
      #Load the MySQL DB schema:
      exec { 'mysql_schema_load':
        user    => 'root',
        path    => '/usr/bin:/usr/sbin:/bin/:/sbin',
        command => "mysql -u ${db_user} -p${db_password} ${db_name} < ${server_db_schema_path} && touch /etc/icinga2/mysql_schema_loaded.txt",
        creates => '/etc/icinga2/mysql_schema_loaded.txt',
        require => Package[$icinga2_server_db_connector_package],
      }
    }

    'pgsql': {
      #Load the Postgres DB schema:
      exec { 'postgres_schema_load':
        user    => 'root',
        path    => '/usr/bin:/usr/sbin:/bin/:/sbin',
        command => "su - postgres -c 'export PGPASSWORD='\\''${db_password}'\\'' && psql -U ${db_user} -h ${db_host} -d ${db_name} < ${server_db_schema_path}' && export PGPASSWORD='' && touch /etc/icinga2/postgres_schema_loaded.txt",
        creates => '/etc/icinga2/postgres_schema_loaded.txt',
        require => Package[$icinga2_server_db_connector_package],
      }
    }

    default: { fail("${server_db_type} is not supported!") }
  }

}
