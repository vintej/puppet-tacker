# Parameters for puppet-tacker
#
class tacker::params {
  #include ::openstacklib::defaults

  $client_package_name = 'git+https://github.com/openstack/python-tackerclient.git@885b53b6d0b18de61b8e0f3f48367a104ca97d4e'
  case $::osfamily {
    'RedHat': {
      $package_name     = 'git+https://github.com/openstack/tacker@stable/mitaka'
      $service_name     = 'openstack-tacker-server'
    }
    'Debian': {
      $package_name     = 'git+https://github.com/openstack/tacker.git@de6cc86ae0c065d67f0607170ab2a2d8d83cc947'
      $service_name     = 'tacker-server'
      $sqlite_package_name  = 'python-pysqlite2'
      $pymysql_package_name = 'python-pymysql'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    } # Case $::osfamily
  }
}
