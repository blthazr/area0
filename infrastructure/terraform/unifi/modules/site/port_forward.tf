# UniFi Port Forward
resource "unifi_port_forward" "http" {
  for_each = { for forward_id, forward in var.port_forward : forward_id => forward }

  dst_port               = each.value.dst_port
  fwd_ip                 = each.value.fwd_ip
  fwd_port               = each.value.fwd_port
  log                    = each.value.log
  name                   = each.value.name
  port_forward_interface = each.value.port_forward_interface
  protocol               = each.value.protocol
  site                   = unifi_site.site.name
  src_ip                 = each.value.src_ip
}
