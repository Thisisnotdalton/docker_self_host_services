locals {
  proxy_config_output_directory = "./proxy_config"
  oidc_issuer_url         = "${var.keycloak_public_url}/realms/${keycloak_realm.realm.realm}"
  traefik_config_output_directory = "./traefik_config"
}

module "oauth_clients" {
  source                   = "./oauth_client"
  for_each                 = var.application_ports
  application_id           = each.key
  keycloak_realm_id        = keycloak_realm.realm.realm
  proxy_config_output_directory         = local.proxy_config_output_directory
  traefik_config_output_directory         = local.traefik_config_output_directory
  oidc_issuer_url          = local.oidc_issuer_url
  callback_url             = "${var.oauth_application_base_url}/${each.key}/oauth/callback"
  ssl_insecure_skip_verify = var.ssl_insecure_skip_verify
  cookie_domain            = var.cookie_domain
}

