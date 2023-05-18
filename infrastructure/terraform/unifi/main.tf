terraform {
  cloud {
    organization = "blthazr"

    workspaces {
      name = "home-unifi-provisioner"
    }
  }
}

data "sops_file" "config_secrets" {
  source_file = "../../config/secret.sops.yaml"
}

locals {
  config_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.config_secrets.raw)))
  unifi_sites    = yamldecode(file("../../config/unifi.yaml"))
}

provider "unifi" {
  username       = local.config_secrets.unifi.username
  password       = local.config_secrets.unifi.password
  api_url        = local.config_secrets.unifi.url
  allow_insecure = local.config_secrets.unifi.insecure
}

module "site" {
  source   = "./modules/site"
  for_each = local.unifi_sites.sites

  name          = each.value.name
  ap_groups     = try(each.value.ap_groups, {})
  clients       = try(each.value.clients, {})
  devices       = try(each.value.devices, {})
  gateways      = try(each.value.gateways, {})
  networks      = try(each.value.networks, {})
  port_forward  = try(each.value.port_forwarding, {})
  port_profiles = try(each.value.port_profiles, {})
  secrets       = try(local.config_secrets.sites, {})
  user_groups   = try(each.value.user_groups, {})
}
