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

variable "callback_urls" {
  description = "The OAuth2 client redirect urls after signing in."
  type        = list(string)
}

variable "proxy_config_output_directory" {
  description = "The directory to write output OAuth2 Proxy config files to."
  type        = string
}

variable "ssl_insecure_skip_verify" {
  description = "Whether to skip SSL/TLS verification for HTTPS."
  type        = bool
  default = false
}

variable "cookie_domain" {
  type = string
  description = "The public domain to assign to cookies."
}

variable "application_servers" {
  type = list(string)
  description = "The servers to direct proxied requests to; this should only be set for non-container hosted services."
  default = []
}

variable "traefik_config_output_directory" {
  description = "The directory to write output traefik config files to."
  type        = string
}

variable "allowed_roles" {
  description = "Optional list of string role names to restrict access to for this proxy."
  type = list(string)
}