resource "keycloak_realm" "realm" {
  realm                          = var.keycloak_realm
  display_name                   = "${var.keycloak_realm} Users"
  registration_allowed           = var.registration_allowed
  verify_email                   = true
  registration_email_as_username = true
  login_with_email_allowed       = true
  duplicate_emails_allowed       = false
  smtp_server {
    from              = var.smtp_from_email
    from_display_name = var.smtp_from_name
    host              = var.smtp_host
    port              = var.smtp_port
    auth {
      password = var.smtp_password
      username = var.smtp_username
    }
    starttls = true
  }
}

resource "keycloak_role" "realm_roles" {
  for_each    = var.keycloak_roles
  name        = each.key
  realm_id    = keycloak_realm.realm.realm
  description = each.value
}

resource "keycloak_group" "realm_groups" {
  for_each = var.keycloak_group_roles
  name     = each.key
  realm_id = keycloak_realm.realm.realm
}

resource "keycloak_group_roles" "realm_group_roles" {
  for_each = var.keycloak_group_roles
  group_id = keycloak_group.realm_groups[each.key].id
  realm_id = keycloak_realm.realm.realm
  role_ids = [
    for role_name in each.value :
    keycloak_role.realm_roles[role_name].id
  ]
}

resource "keycloak_openid_client_scope" "groups" {
  realm_id = keycloak_realm.realm.realm
  name        = "groups"
  description = "Group membership scope"
  include_in_token_scope = true
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups_mapper" {
  realm_id        = keycloak_realm.realm.realm
  client_scope_id = keycloak_openid_client_scope.groups.id

  name              = "groups"
  claim_name        = "groups"
  full_path         = false

  add_to_id_token     = true
  add_to_access_token = true
  add_to_userinfo     = true
}

resource "keycloak_realm_default_client_scopes" "realm_defaults" {
  realm_id = keycloak_realm.realm.realm

  default_scopes = [
    "profile",
    "email",
    "roles",
    keycloak_openid_client_scope.groups.name
  ]
}