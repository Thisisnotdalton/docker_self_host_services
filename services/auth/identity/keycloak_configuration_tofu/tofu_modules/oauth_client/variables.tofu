variable "keycloak_realm_id" {
  description = "The id of the Keycloak realm to create this OAuth client for."
  type        = string
}

variable "oidc_issuer_url" {
  description = "The URL endpoint to connect to Keycloak and get oidc config."
  type        = string
}

variable "application_id" {
  description = "The id of the application to create an OAuth client for. Used for generating the output file names."
  type        = string
}

variable "callback_url" {
  description = "The OAuth2 client redirect url after signing in."
  type        = string
}

variable "output_directory" {
  description = "The directory to write output files to."
  type        = string
}

variable "ssl_insecure_skip_verify" {
  description = "Whether to skip SSL/TLS verification for HTTPS."
  type        = bool
  default = false
}
