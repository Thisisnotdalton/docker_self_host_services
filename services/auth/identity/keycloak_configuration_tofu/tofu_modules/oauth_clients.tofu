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
  oidc_issuer_url         = "${var.keycloak_public_url}/realms/${keycloak_realm.realm.realm}"
}

module "oauth_clients" {
  source                   = "./oauth_client"
  for_each                 = local.application_callback_urls
  application_id           = each.key
  keycloak_realm_id        = keycloak_realm.realm.realm
  output_directory         = local.config_output_directory
  oidc_issuer_url          = local.oidc_issuer_url
  callback_url             = each.value
  ssl_insecure_skip_verify = var.ssl_insecure_skip_verify
}

