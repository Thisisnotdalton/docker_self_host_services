locals {
  application_base_redirect_url = var.oauth_application_base_url
  applications = [
    "whoami",
    "vaultwarden"
  ]
  application_redirect_urls = {
    for application_id in local.applications :
    application_id => "${local.application_base_redirect_url}/${application_id}"
  }
  config_output_directory = "./config"
}

module "oauth_clients" {
  source            = "./oauth_client"
  for_each          = local.application_redirect_urls
  application_id    = each.key
  redirect_url      = each.value
  keycloak_realm_id = keycloak_realm.realm.id
  output_directory  = local.config_output_directory
  keycloak_url      = var.keycloak_url
}

