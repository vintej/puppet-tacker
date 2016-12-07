# == Class: tacker::keystone::auth
#
# Configures tacker user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (required) Password for tacker user.
#
# [*auth_name*]
#   Username for tacker service. Defaults to 'tacker'.
#
# [*email*]
#   Email for tacker user. Defaults to 'tacker@localhost'.
#
# [*tenant*]
#   Tenant for tacker user. Defaults to 'services'.
#
# [*configure_endpoint*]
#   Should tacker endpoint be configured? Defaults to 'true'.
#
# [*configure_user*]
#   (Optional) Should the service user be configured?
#   Defaults to 'true'.
#
# [*configure_user_role*]
#   (Optional) Should the admin role be configured for the service user?
#   Defaults to 'true'.
#
# [*service_type*]
#   Type of service. Defaults to 'nfv-orchestration'.
#
# [*region*]
#   Region for endpoint. Defaults to 'RegionOne'.
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of 'tacker'.
#
# [*service_description*]
#   (optional) Description of the service.
#   Default to 'tacker NFV orchestration Service'
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:9890')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:9890')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:9890')
#
class tacker::keystone::auth (
  $password,
  $auth_name           = 'tacker',
  $email               = 'tacker@localhost',
  $tenant              = 'services',
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = 'tacker',
  $service_description = 'tacker NFV orchestration Service',
  $service_type        = 'nfv-orchestration',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:9890',
  $admin_url           = 'http://127.0.0.1:9890',
  $internal_url        = 'http://127.0.0.1:9890',
) {

  include ::tacker::deps

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~> Service <| name == 'tacker-server' |>
  }
  Keystone_endpoint["${region}/${service_name}::${service_type}"]  ~> Service <| name == 'tacker-server' |>

  keystone::resource::service_identity { 'tacker':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }

}
