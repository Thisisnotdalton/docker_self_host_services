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

variable "application_servers" {
  type = map(list(string))
  description = "Mapping of unique application ids to external servers to assign as load balancers. A list with an empty string is sufficient for container services which apply their own Traefik labels."
  default = {
    "whoami" : [""]
    "vaultwarden" : [""]
    "vaultwarden_sso": [""]
  }
}

variable "application_extra_redirect_urls" {
  type = map(list(string))
  description = "Optional additional redirect urls for oauth clients."
  default = {
    "vaultwarden_sso": [""]
  }
}