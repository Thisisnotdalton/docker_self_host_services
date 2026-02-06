terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
  encryption {
    key_provider "pbkdf2" "key_provider" {
      # Specify a long / complex passphrase (min. 16 characters)
      passphrase = var.state_encryption_passphrase

      # Adjust the key length to the encryption method (default: 32)
      key_length = 32

      # Specify the number of iterations (min. 200.000, default: 600.000)
      iterations = 600000

      # Specify the salt length in bytes (default: 32)
      salt_length = 32

      # Specify the hash function (sha256 or sha512, default: sha512)
      hash_function = "sha512"
    }
    method "aes_gcm" "method" {
      keys = key_provider.pbkdf2.key_provider
    }
    state {
      method   = method.aes_gcm.method
      enforced = true
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  url = var.keycloak_url
  username = var.keycloak_username
  password = var.keycloak_password
}