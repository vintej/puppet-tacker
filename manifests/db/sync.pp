#
# Class to execute tacker-db-manage
#
# == Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the tacker-dbsync command.
#   Defaults to '--config-file /etc/tacker/tacker.conf'
#
# [*user*]
#   (optional) User to run dbsync command.
#   Defaults to 'congress'
#
class tacker::db::sync(
  $extra_params  = '--config-file /usr/local/etc/tacker/tacker.conf',
  $user = 'tacker',
) {

  include ::tacker::deps
  include ::tacker::params
  include ::tacker::server
  exec['changing-server-certificate'] -> exec['tacker-db-sync']
  exec { 'tacker-db-sync':
    command     => "/usr/local/bin/tacker-db-manage --config-file /usr/local/etc/tacker/tacker.conf upgrade head",
    path        => ['/bin', '/usr/bin'],
    #user        => $user,
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    subscribe   => [
      Anchor['tacker::install::end'],
      Anchor['tacker::config::end'],
      Anchor['tacker::dbsync::begin']
    ],
    notify      => Anchor['tacker::dbsync::end'],
  }

}
