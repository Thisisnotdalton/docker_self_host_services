locals {
  application_id           = var.application_id
  proxy_config_output_path = "${var.proxy_config_output_directory}/${local.application_id}"
  load_balancers           = [
    for url in var.application_servers :
    url
    if url != ""
  ]
}

resource "time_rotating" "rotate" {
  rotation_days = 10
}

resource "keycloak_openid_client" "client" {
  realm_id    = var.keycloak_realm_id
  client_id   = "${local.application_id}-client"
  name        = "${local.application_id} client"
  enabled     = true
  access_type = "CONFIDENTIAL"
  client_secret_regenerate_when_changed = {
    rotation = time_rotating.rotate.rotation_rfc3339
  }
  standard_flow_enabled = true
  valid_redirect_uris   = var.callback_urls
}

resource "random_bytes" "cookie_secret" {
  length = 32
}

resource "local_file" "oauth_cookie_secret" {
  filename        = "${local.proxy_config_output_path}/oauth_cookie_secret"
  content_base64  = random_bytes.cookie_secret.base64
  file_permission = "0600"
}

resource "local_file" "oauth_application_secret" {
  filename        = "${local.proxy_config_output_path}/oauth_client_secret"
  content_base64 = base64encode(keycloak_openid_client.client.client_secret)
  file_permission = "0600"
}

locals {
  proxy_config = templatefile(
    "${path.module}/oauth2-proxy.cfg.tftpl",
    {
      client_id                = keycloak_openid_client.client.client_id
      oidc_issuer_url          = var.oidc_issuer_url
      application_id           = local.application_id
      redirect_url             = var.callback_urls[0]
      ssl_insecure_skip_verify = var.ssl_insecure_skip_verify
      cookie_domain            = var.cookie_domain
      allowed_roles            = var.allowed_roles
    }
  )
  traefik_config = templatefile(
    "${path.module}/traefik-ingress.yml.tftpl",
    {
      public_host    = var.cookie_domain
      application_id = local.application_id
      urls           = local.load_balancers
    }
  )
}

resource "local_file" "proxy_config" {
  filename = "${local.proxy_config_output_path}/oauth2-proxy.cfg"
  content  = local.proxy_config
}

resource "local_file" "traefik_config" {
  filename = "${var.traefik_config_output_directory}/traefik_config_${local.application_id}.yaml"
  content  = local.traefik_config
}