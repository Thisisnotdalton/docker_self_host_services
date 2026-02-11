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