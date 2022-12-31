data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
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
