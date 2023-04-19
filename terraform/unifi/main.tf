terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
  }
  required_version = ">= 1.3.0"
}
