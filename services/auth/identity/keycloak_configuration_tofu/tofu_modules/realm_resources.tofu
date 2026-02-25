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
  for_each = var.group_roles
  name     = each.key
  realm_id = keycloak_realm.realm.realm
}

resource "keycloak_group_roles" "realm_group_roles" {
  for_each = var.group_roles
  group_id = keycloak_group.realm_groups[each.key].id
  realm_id = keycloak_realm.realm.realm
  role_ids = [
    for role_name in each.value :
    keycloak_role.realm_roles[role_name].id
  ]
}