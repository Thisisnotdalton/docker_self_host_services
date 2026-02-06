locals {
  application_id="whoami"
  secrets_output_path="./secrets/${local.application_id}"
}

resource "time_rotating" "rotate" {
  rotation_days = 10
}

resource "keycloak_openid_client" "client" {
  realm_id    = keycloak_realm.realm.id
  client_id   = "${local.application_id}-client"
  name        = "${local.application_id} client"
  enabled     = true
  access_type = "CONFIDENTIAL"
  client_secret_regenerate_when_changed = {
    rotation = time_rotating.rotate.rotation_rfc3339
  }
}

resource "random_bytes" "cookie_secret" {
  length = 32
}

resource "local_file" "oauth_cookie_secret" {
  filename = "${local.secrets_output_path}/oauth_cookie_secret"
  content_base64 = random_bytes.cookie_secret.base64
  file_permission = "0600"
}

resource "local_file" "oauth_application_secret" {
  filename = "${local.secrets_output_path}/oauth_client_secret"
  content_base64 = base64encode(keycloak_openid_client.client.client_secret)
  file_permission = "0600"
}
