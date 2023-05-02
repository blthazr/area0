# Cloudflare DNS Records
resource "cloudflare_record" "record" {
  for_each = { for record in var.dns_records : (record.id != null ? record.id : "${record.type}_${record.name}_${record.priority}") => record }

  allow_overwrite = each.value.allow_overwrite
  comment         = each.value.comment
  name            = each.value.name
  priority        = each.value.priority
  proxied         = contains(["A", "CNAME"], each.value.type) ? try(each.value.proxied, true) : try(each.value.proxied, null)
  ttl             = each.value.ttl
  type            = each.value.type
  value           = each.value.public_address ? chomp(data.http.ipv4.response_body) : each.value.value
  zone_id         = cloudflare_zone.zone.id
}
