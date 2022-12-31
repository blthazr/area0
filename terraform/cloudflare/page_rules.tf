resource "cloudflare_page_rule" "public_domain_plex_bypass" {
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  target   = "plex.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}/*"
  status   = "active"
  priority = 1

  actions {
    cache_level         = "bypass"
    disable_performance = true
  }
}

resource "cloudflare_page_rule" "public_domain_home_assistant_bypass" {
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  target   = "home-assistant.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  status   = "active"
  priority = 2

  actions {
    cache_level = "bypass"
  }
}
