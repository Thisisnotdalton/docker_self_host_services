terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}