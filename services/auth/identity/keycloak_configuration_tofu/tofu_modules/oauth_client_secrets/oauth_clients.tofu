locals {
  application_id      = var.application_id
  secrets_output_path = "${var.secrets_output_directory}/${local.application_id}"
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
  valid_redirect_uris = [
    var.redirect_url
  ]
}

resource "random_bytes" "cookie_secret" {
  length = 32
}

resource "local_file" "oauth_cookie_secret" {
  filename        = "${local.secrets_output_path}/oauth_cookie_secret"
  content_base64  = random_bytes.cookie_secret.base64
  file_permission = "0600"
}

resource "local_file" "oauth_application_secret" {
  filename        = "${local.secrets_output_path}/oauth_client_secret"
  content_base64 = base64encode(keycloak_openid_client.client.client_secret)
  file_permission = "0600"
}
