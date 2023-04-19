# UniFi Clients

resource "unifi_user" "user" {
  for_each               = { for client_id, client in local.clients: client_id => client if can(client.mac) }

  allow_existing         = try(each.value.allow_existing, true)
  blocked                = try(each.value.blocked, false)
  dev_id_override        = try(each.value.device_fingerprint_id, null)
  fixed_ip               = try(each.value.fixed_ip, null)
  local_dns_record       = try(each.value.dns_record, null)
  network_id             = try(each.value.network_id, null)
  name                   = try(each.value.name, title(replace(each.key, "_", " ")))
  note                   = try(trimspace("${each.value.note}\n\nmanaged by Terraform"), "Managed by Terraform")
  mac                    = each.value.mac
  site                   = try(each.value.site, unifi_site.default.name)
  skip_forget_on_destroy = try(each.value.skip_forget_on_destroy, true)
  user_group_id          = try(each.value.user_group_id, null)
}
