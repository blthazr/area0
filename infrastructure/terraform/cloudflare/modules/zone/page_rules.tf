# Cloudflare Page Rules
resource "cloudflare_page_rule" "page_rule" {
  for_each = { for rule in var.page_rules : rule.id => rule }

  actions {
    always_use_https         = lookup(each.value.actions, "always_use_https")
    automatic_https_rewrites = lookup(each.value.actions, "automatic_https_rewrites")
    cache_level              = lookup(each.value.actions, "cache_level")
    disable_apps             = lookup(each.value.actions, "disable_apps")
    disable_performance      = lookup(each.value.actions, "disable_performance")
    disable_railgun          = lookup(each.value.actions, "disable_railgun")
    disable_security         = lookup(each.value.actions, "disable_security")
    disable_zaraz            = lookup(each.value.actions, "disable_zaraz")
    rocket_loader            = lookup(each.value.actions, "rocket_loader")
  }
  priority = each.value.priority
  status   = each.value.status
  target   = each.value.target
  zone_id  = cloudflare_zone.zone.id
}
