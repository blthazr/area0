terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_account" "account" {
  name              = var.account_name
  enforce_twofactor = var.account_enforce_twofactor
  type              = var.account_type
}
