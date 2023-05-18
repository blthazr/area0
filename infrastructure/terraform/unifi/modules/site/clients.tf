# UniFi Users
resource "unifi_user" "user" {
  for_each = { for client_id, client in var.clients : (lower(replace("${client.mac}", ":", ""))) => client if(client.mac != null) }

  allow_existing         = each.value.allow_existing
  blocked                = each.value.blocked
  dev_id_override        = each.value.unifi_device_fingerprint_id
  fixed_ip               = each.value.ip_address
  local_dns_record       = each.value.fqdn
  mac                    = each.value.mac
  name                   = try(each.value.name, lower(replace(each.value.mac, ":", "")))
  network_id             = each.value.ip_address != null ? try(unifi_network.network[each.value.network].id, try(each.value.network_id, null)) : null
  note                   = try(trimspace("${each.value.note}\n\nmanaged by Terraform"), "Managed by Terraform")
  site                   = unifi_site.site.name
  skip_forget_on_destroy = each.value.skip_forget_on_destroy
}
