locals {
  applications = [
    "whoami",
    "vaultwarden"
  ]
  application_callback_urls = {
    for application_id in local.applications :
    application_id => "${var.oauth_application_base_url}/${application_id}"
  }
  config_output_directory = "./config"
}

module "oauth_clients" {
  source            = "./oauth_client"
  for_each          = local.application_callback_urls
  application_id    = each.key
  keycloak_realm_id = keycloak_realm.realm.id
  output_directory  = local.config_output_directory
  keycloak_internal_url = var.keycloak_internal_url
  callback_url = each.value
}

