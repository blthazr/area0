data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

data "cloudflare_zones" "public_domain" {
  filter {
    name = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  }
}

resource "cloudflare_record" "public_domain_apex" {
  name    = "hsv-1"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = chomp(data.http.ipv4.response_body)
  proxied = true
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "public_domain_root" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "hsv-1.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "public_domain_www" {
  name    = "www"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "hsv-1.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "txt_root_spf" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "v=spf1 a mx ~all"
  proxied = false
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "mx_root_mx3" {
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value    = "mx3.name.com"
  proxied  = false
  type     = "MX"
  ttl      = 1
  priority = 20
}

resource "cloudflare_record" "mx_root_mx4" {
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value    = "mx4.name.com"
  proxied  = false
  type     = "MX"
  ttl      = 1
  priority = 50
}

resource "cloudflare_record" "mx_root_mx5" {
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value    = "mx5.name.com"
  proxied  = false
  type     = "MX"
  ttl      = 1
  priority = 60
}

resource "cloudflare_record" "mx_root_mx6" {
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value    = "mx6.name.com"
  proxied  = false
  type     = "MX"
  ttl      = 1
  priority = 30
}

resource "cloudflare_record" "mx_root_mx7" {
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value    = "mx7.name.com"
  proxied  = false
  type     = "MX"
  ttl      = 1
  priority = 10
}

resource "cloudflare_record" "mx_root_mx8" {
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value    = "mx8.name.com"
  proxied  = false
  type     = "MX"
  ttl      = 1
  priority = 40
}

#
# geoip blocking
#

resource "cloudflare_filter" "countries" {
  zone_id     = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  description = "Expression to block all countries except US"
  expression  = "(ip.geoip.country ne \"US\")"
}

resource "cloudflare_firewall_rule" "countries" {
  zone_id     = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  description = "Firewall rule to block all countries except US"
  filter_id   = cloudflare_filter.countries.id
  action      = "block"
}

#
# bots
#

resource "cloudflare_filter" "bots" {
  zone_id     = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  description = "Expression to block bots determined by CF"
  expression  = "(cf.client.bot)"
}

resource "cloudflare_firewall_rule" "bots" {
  zone_id     = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  description = "Firewall rule to block bots determined by CF"
  filter_id   = cloudflare_filter.bots.id
  action      = "block"
}

#
# block threats less than medium
#

resource "cloudflare_filter" "threats" {
  zone_id     = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  description = "Expression to block medium threats"
  expression  = "(cf.threat_score gt 14)"
}

resource "cloudflare_firewall_rule" "threats" {
  zone_id     = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  description = "Firewall rule to block medium threats"
  filter_id   = cloudflare_filter.threats.id
  action      = "block"
}

resource "cloudflare_page_rule" "public_domain_plex_bypass" {
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  target   = "plex.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}/*"
  status   = "active"
  priority = 1

  actions {
    cache_level = "bypass"
  }
}

resource "cloudflare_page_rule" "public_domain_home_assistant_bypass" {
  zone_id  = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  target   = "home-assistant.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}/*"
  status   = "active"
  priority = 2

  actions {
    cache_level = "bypass"
  }
}

resource "cloudflare_zone_settings_override" "public_domain_settings" {
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  settings {
    ssl                      = "strict"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    tls_1_3                  = "zrt"
    automatic_https_rewrites = "on"
    universal_ssl            = "on"
    browser_check            = "on"
    challenge_ttl            = 1800
    privacy_pass             = "on"
    security_level           = "medium"
    brotli                   = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    rocket_loader       = "off"
    always_online       = "off"
    development_mode    = "off"
    http3               = "on"
    zero_rtt            = "on"
    ipv6                = "on"
    websockets          = "on"
    opportunistic_onion = "on"
    pseudo_ipv4         = "off"
    ip_geolocation      = "on"
    email_obfuscation   = "on"
    server_side_exclude = "on"
    hotlink_protection  = "off"
    security_header {
      enabled = false
    }
  }
}
