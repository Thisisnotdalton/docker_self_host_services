locals {
  proxy_config_output_directory   = "./proxy_config"
  oidc_issuer_url                 = "${var.keycloak_public_url}/realms/${keycloak_realm.realm.realm}"
  traefik_config_output_directory = "./traefik_config"
}

module "oauth_clients" {
  source                          = "./oauth_client"
  for_each                        = var.oauth2_clients
  application_id                  = each.key
  application_servers             = each.value.extra_redirect_urls
  keycloak_realm_id               = keycloak_realm.realm.realm
  proxy_config_output_directory   = local.proxy_config_output_directory
  traefik_config_output_directory = local.traefik_config_output_directory
  oidc_issuer_url                 = local.oidc_issuer_url
  callback_urls = concat(
    each.value.extra_redirect_urls,
    ["${var.oauth_application_base_url}/${each.key}/oauth/callback"]
  )
  ssl_insecure_skip_verify = var.ssl_insecure_skip_verify
  cookie_domain            = var.cookie_domain
  allowed_roles            = each.value.roles
  service_override         = each.value.service
  traefik_path_condition   = each.value.traefik_path_condition
  strip_path_prefix        = each.value.strip_path_prefix
  sso_client_redirect_url  = each.value.sso_client_redirect_url
}

