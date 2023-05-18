# UniFi USG Settings
resource "unifi_setting_usg" "usg_settings" {
  for_each = { for gateway_id, gateway in var.gateways : gateway_id => gateway }

  dhcp_relay_servers         = each.value.dhcp_relay_servers
  firewall_guest_default_log = each.value.log.guest
  firewall_lan_default_log   = each.value.log.lan
  firewall_wan_default_log   = each.value.log.wan
  site                       = unifi_site.site.name
}
