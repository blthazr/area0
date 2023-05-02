# Cloudflare Firewall Rules
locals {
  firewall_rules = var.firewall_rules != null ? {
    for rule in flatten(var.firewall_rules) :
    format("%s-%s",
      rule.action,
      md5(rule.expression),
    ) => rule
  } : {}
}

resource "cloudflare_filter" "filter" {
  for_each = local.firewall_rules

  description = try(each.value.description, null)
  expression  = each.value.expression
  paused      = each.value.paused
  ref         = try(each.value.ref, null)
  zone_id     = cloudflare_zone.zone.id
}

resource "cloudflare_firewall_rule" "firewall_rule" {
  for_each = local.firewall_rules

  action      = each.value.action
  description = try(each.value.description, null)
  filter_id   = cloudflare_filter.filter[each.key].id
  paused      = each.value.paused
  priority    = each.value.priority
  zone_id     = cloudflare_zone.zone.id
}
