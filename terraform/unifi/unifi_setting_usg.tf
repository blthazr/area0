# UniFi USG Settings

resource "unifi_setting_usg" "usg_settings" {
  firewall_guest_default_log = true
  firewall_lan_default_log = false
  firewall_wan_default_log = true
  site = unifi_site.default.name
}
