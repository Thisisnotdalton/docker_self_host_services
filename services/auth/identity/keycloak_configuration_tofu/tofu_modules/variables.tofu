variable "state_encryption_passphrase" {
  type        = string
  description = "The passphrase to use for encrypting the OpenTofu state."
  sensitive   = true
}

variable "keycloak_internal_url" {
  description = "The internal URL endpoint to connect to Keycloak."
  type        = string
}

variable "keycloak_public_url" {
  description = "The public URL endpoint to connect to Keycloak."
  type        = string
}

variable "keycloak_username" {
  description = "The user to authenticate for Keycloak management."
  type        = string
  sensitive   = true
}

variable "keycloak_password" {
  description = "The password to authenticate for Keycloak management."
  type        = string
  sensitive   = true
}

variable "keycloak_realm" {
  description = "The realm name to create."
  type        = string
}

variable "registration_allowed" {
  description = "Whether to allow new users to sign up."
  type        = bool
  default     = false
}

variable "smtp_host" {
  description = "The SMTP host for sending emails."
  type        = string
}

variable "smtp_port" {
  description = "The port to send SMTP requests to."
  type        = number
  default     = 2525
}

variable "smtp_username" {
  description = "The username to authenticate for the SMTP server."
  type        = string
}

variable "smtp_password" {
  description = "The password to authenticate for the SMTP server."
  type        = string
}

variable "smtp_from_email" {
  description = "The email for the Keycloak email sender."
  type        = string
}

variable "smtp_from_name" {
  description = "The display name for the Keycloak email sender."
  type        = string
  default     = "Keycloak"
}

variable "oauth_application_base_url" {
  description = "The base url to use for generating template application redirect urls."
  type        = string
}

variable "ssl_insecure_skip_verify" {
  description = "Whether to skip SSL/TLS verification for HTTPS."
  type        = bool
  default     = false
}

variable "cookie_domain" {
  type        = string
  description = "The domain to assign to cookies."
}

variable "keycloak_roles" {
  description = "Mapping of Keycloak role ids to descriptions."
  type = map(string)
  default = {
    "admin" : "A user with this role should be provided access to admin panels for managing services.",
    "trusted" : "A user with this role may be provided access to more services than a default user."
  }
}

variable "keycloak_group_roles" {
  description = "Mapping of group ids to lists of role ids to assign to that group."
  type = map(list(string))
  default = {
    "admin" : ["admin", "trusted"],
    "trusted" : ["trusted"]
  }
}

variable "application_servers" {
  type = map(list(string))
  description = "Mapping of unique application ids to external servers to assign as load balancers. A list with an empty string is sufficient for container services which apply their own Traefik labels."
  default = {
    "whoami" : [""]
    "vaultwarden" : [""]
  }
}

variable "application_extra_redirect_urls" {
  type = map(list(string))
  description = "Optional additional redirect urls for oauth clients."
  default = {
    "whoami": ["https://also-accept-this-redirect"]
  }
}

variable "application_proxy_role_restrictions" {
  type = map(list(string))
  description = "Optional role requirements for oauth clients."
  default = {
    "whoami-admin" : ["admin"]
  }
}
