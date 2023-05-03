terraform {
  cloud {
    organization = "blthazr"

    workspaces {
      name = "home-cloudflare"
    }
  }
}

data "sops_file" "config_secrets" {
  source_file = "../../config/secret.sops.yaml"
}

data "sops_file" "config_domains" {
  source_file = "../../config/domain.sops.yaml"
}

locals {
  config_domains = yamldecode(nonsensitive(data.sops_file.config_domains.raw))
  config_secrets = sensitive(yamldecode(nonsensitive(data.sops_file.config_secrets.raw)))
}

provider "cloudflare" {
  email   = local.config_secrets.cloudflare.email
  api_key = local.config_secrets.cloudflare.api_key
}

module "account" {
  source       = "./modules/account"
  account_name = nonsensitive(local.config_secrets.cloudflare.account_name)
}

module "zone" {
  source   = "./modules/zone"
  for_each = local.config_domains.domains

  account_id     = module.account.account_id
  name           = each.value.name
  paused         = try(each.value.paused, false)
  plan           = try(each.value.plan, "free")
  type           = try(each.value.type, "full")
  dns_records    = try(each.value.dns_records, [])
  firewall_rules = try(each.value.firewall_rules, [])
  page_rules     = try(each.value.page_rules, [])
}
