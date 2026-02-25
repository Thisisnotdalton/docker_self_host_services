locals {
  proxy_config_output_directory   = "./proxy_config"
  oidc_issuer_url                 = "${var.keycloak_public_url}/realms/${keycloak_realm.realm.realm}"
  traefik_config_output_directory = "./traefik_config"
}

module "oauth_clients" {
  source                          = "./oauth_client"
  for_each                        = var.application_servers
  application_id                  = each.key
  application_servers             = each.value
  keycloak_realm_id               = keycloak_realm.realm.realm
  proxy_config_output_directory   = local.proxy_config_output_directory
  traefik_config_output_directory = local.traefik_config_output_directory
  oidc_issuer_url                 = local.oidc_issuer_url
  callback_urls = concat(
    ["${var.oauth_application_base_url}/${each.key}/oauth/callback"],
    lookup(var.application_extra_redirect_urls, each.key, [])
  )
  ssl_insecure_skip_verify = var.ssl_insecure_skip_verify
  cookie_domain            = var.cookie_domain
  allowed_roles = lookup(var.application_proxy_role_restrictions, each.key, [])
}

