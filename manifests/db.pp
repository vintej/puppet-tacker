# == Class: tacker::db
#
#  Configure the tacker database
#
# === Parameters
#
# [*database_connection*]
#   (Optional) Url used to connect to database.
#   Defaults to "sqlite:////var/lib/tacker/tacker.sqlite".
#
# [*database_idle_timeout*]
#   (Optional) Timeout when db connections should be reaped.
#   Defaults to $::os_service_default
#
# [*database_max_retries*]
#   (Optional) Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   Defaults to $::os_service_default
#
# [*database_retry_interval*]
#   (Optional) Interval between retries of opening a database connection.
#   Defaults to $::os_service_default
#
# [*database_min_pool_size*]
#   (Optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*database_max_pool_size*]
#   (Optional)Maximum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*database_max_overflow*]
#   (Optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to $::os_service_default
#
class tacker::db (
  $database_connection     = 'sqlite:////var/lib/tacker/tacker.sqlite',
  $database_idle_timeout   = $::os_service_default,
  $database_min_pool_size  = $::os_service_default,
  $database_max_pool_size  = $::os_service_default,
  $database_max_retries    = $::os_service_default,
  $database_retry_interval = $::os_service_default,
  $database_max_overflow   = $::os_service_default,
  $sync_db                 = true,
) {

  include ::tacker::deps
  include ::tacker::params

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use tacker::<myparam> if tacker::db::<myparam> isn't specified.
  $database_connection_real = pick($::tacker::database_connection, $database_connection)
  $database_idle_timeout_real = pick($::tacker::database_idle_timeout, $database_idle_timeout)
  $database_min_pool_size_real = pick($::tacker::database_min_pool_size, $database_min_pool_size)
  $database_max_pool_size_real = pick($::tacker::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::tacker::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::tacker::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::tacker::database_max_overflow, $database_max_overflow)
  $sync_db_real = pick($::tacker::sync_db, $sync_db)

  validate_re($database_connection_real,
    '^(sqlite|mysql(\+pymysql)?|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $database_connection_real {
    /^mysql(\+pymysql)?:\/\//: {
      require 'mysql::bindings'
      require 'mysql::bindings::python'
      if $database_connection_real =~ /^mysql\+pymysql/ {
        $backend_package = $::tacker::params::pymysql_package_name
      } else {
        $backend_package = false
      }
    }
    /^postgresql:\/\//: {
      $backend_package = false
      require 'postgresql::lib::python'
    }
    /^sqlite:\/\//: {
      $backend_package = $::tacker::params::sqlite_package_name
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  if $backend_package and !defined(Package[$backend_package]) {
    package {'tacker-backend-package':
      ensure => present,
      name   => $backend_package,
      tag    => 'openstack',
    }
  }

  tacker_config {
    'database/connection':     value => $database_connection_real, secret => true;
    'database/idle_timeout':   value => $database_idle_timeout_real;
    'database/min_pool_size':  value => $database_min_pool_size_real;
    'database/max_retries':    value => $database_max_retries_real;
    'database/retry_interval': value => $database_retry_interval_real;
    'database/max_pool_size':  value => $database_max_pool_size_real;
    'database/max_overflow':   value => $database_max_overflow_real;
  }

  if $sync_db_real {
    include ::tacker::db::sync
  }

}

 # validate_re($database_connection,
  #  '^(sqlite|mysql(\+pymysql)?|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')
 #oslo::db { 'tacker_config':
  #  connection     => $database_connection,
  #  idle_timeout   => $database_idle_timeout,
  #  min_pool_size  => $database_min_pool_size,
  #  max_retries    => $database_max_retries,
  #  retry_interval => $database_retry_interval,
  #  max_pool_size  => $database_max_pool_size,
  #  max_overflow   => $database_max_overflow,
  #}

#}
