terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}
