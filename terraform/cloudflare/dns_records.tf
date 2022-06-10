# get current ip address
data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

#
# base records
#

resource "cloudflare_record" "apex_hsv_1" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "hsv-1"
  type    = "A"
  value   = chomp(data.http.ipv4.body)
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_root" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type    = "CNAME"
  value   = "hsv-1.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_www" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "www"
  type    = "CNAME"
  value   = "hsv-1.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_wireguard" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "wg"
  type    = "CNAME"
  value   = "hsv-1.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_root_spf" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type    = "TXT"
  value   = "v=spf1 a mx ~all"
  ttl     = 1
  proxied = false
}

#
# name.com email
#

resource "cloudflare_record" "mx_root_mx3" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type     = "MX"
  value    = "mx3.name.com"
  ttl      = 1
  priority = 20
  proxied  = false
}

resource "cloudflare_record" "mx_root_mx4" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type     = "MX"
  value    = "mx4.name.com"
  ttl      = 1
  priority = 50
  proxied  = false
}

resource "cloudflare_record" "mx_root_mx5" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type     = "MX"
  value    = "mx5.name.com"
  ttl      = 1
  priority = 60
  proxied  = false
}

resource "cloudflare_record" "mx_root_mx6" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type     = "MX"
  value    = "mx6.name.com"
  ttl      = 1
  priority = 30
  proxied  = false
}

resource "cloudflare_record" "mx_root_mx7" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type     = "MX"
  value    = "mx7.name.com"
  ttl      = 1
  priority = 10
  proxied  = false
}

resource "cloudflare_record" "mx_root_mx8" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  type     = "MX"
  value    = "mx8.name.com"
  ttl      = 1
  priority = 40
  proxied  = false
}
