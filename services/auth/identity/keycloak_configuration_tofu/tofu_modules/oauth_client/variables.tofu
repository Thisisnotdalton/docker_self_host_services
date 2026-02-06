variable "keycloak_realm_id" {
  description = "The id of the Keycloak realm to create this OAuth client for."
  type        = string
}

variable "keycloak_url" {
  description = "The URL endpoint to connect to Keycloak."
  type        = string
}

variable "application_id" {
  description = "The id of the application to create an OAuth client for. Used for generating the output file names."
  type        = string
}

variable "redirect_url" {
  description = "The OAuth2 client redirect url"
  type        = string
}

variable "output_directory" {
  description = "The directory to write output files to."
  type        = string
}
