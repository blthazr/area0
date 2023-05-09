terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.3.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
  }
  required_version = ">= 1.4.0"
}
