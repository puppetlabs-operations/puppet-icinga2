# == Class: icinga2::database
#
# Managing Icinga2's IDO database
#
class icinga2::database(
  $manage_schema = false,
){

  validate_re($::icinga2::db_type, '^(mysql|pgsql)$', "Database type ${::icinga2::db_type} is not supported!")

  if $::icinga2::db_schema {
    $db_schema = $::icinga2::db_schema
  }
  else {
    $db_schema = $::icinga2::db_type ? {
      'mysql' => $::icinga2::db_schema_mysql,
      'pgsql' => $::icinga2::db_schema_pgsql,
      default => undef,
    }
  }
  validate_absolute_path($db_schema)

  $ido_package = $::icinga2::db_type ? {
    'mysql' => 'icinga2-ido-mysql',
    'pgsql' => 'icinga2-ido-pgsql',
  }

  package { $ido_package:
    ensure   => installed,
    provider => $::icinga2::package_provider,
  }


  if $manage_schema == true {
    if $::icinga2::db_type == 'mysql' {
      # TODO: is there a better way?
      exec { 'mysql_schema_load':
        user    => 'root',
        path    => $::path,
        command => "mysql -h '${::icinga2::db_host}' -u '${::icinga2::db_user}' -p'${::icinga2::db_pass}' '${::icinga2::db_name}' < '${db_schema}' && touch /etc/icinga2/mysql_schema_loaded.txt",
        creates => '/etc/icinga2/mysql_schema_loaded.txt',
        require => Package['icinga2-ido-mysql']
      }
    }
    elsif $::icinga2::db_type == 'pgsql' {
      # TODO: is there a better way?
      if $::icinga2::db_port {
        $port = "-p ${::icinga2::db_port}"
      } else {
        $port = undef
      }

      exec { 'postgres_schema_load':
        user        => 'root',
        path        => $::path,
        environment => [
          "PGPASSWORD=${::icinga2::db_pass}",
        ],
        command     => "psql -U '${::icinga2::db_user}' -h '${::icinga2::db_host}' ${port} -d '${::icinga2::db_name}' < '${db_schema}' && touch /etc/icinga2/postgres_schema_loaded.txt",
        creates     => '/etc/icinga2/postgres_schema_loaded.txt',
        require     => Package['icinga2-ido-pgsql']
      }
    }
  }

}
