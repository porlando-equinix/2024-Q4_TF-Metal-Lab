terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = ">= 1.35.0"
    }
  }
}

provider "equinix" {
  client_id     = var.client_id
  client_secret = var.client_secret
  auth_token    = var.metal_auth_key
}




