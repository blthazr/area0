# UniFi Wireless Networks

resource "unifi_wlan" "home" {
  ap_group_ids              = [data.unifi_ap_group.default.id]
  fast_roaming_enabled      = true
  multicast_enhance         = true
  name                      = "Dunbroch"
  network_id                = unifi_network.network["home"].id
  passphrase                = nonsensitive(data.sops_file.unifi_secrets.data["unifi.networks.home.wlan.passphrase"])
  pmf_mode                  = "optional"
  security                  = "wpapsk"
  site                      = unifi_site.default.name
  user_group_id             = data.unifi_user_group.default.id
  wlan_band                 = "both"
}

resource "unifi_wlan" "guest" {
  ap_group_ids              = [data.unifi_ap_group.default.id]
  fast_roaming_enabled      = true
  is_guest                  = true
  multicast_enhance         = true
  name                      = "Dunbroch-Guest"
  network_id                = unifi_network.network["guest"].id
  passphrase                = nonsensitive(data.sops_file.unifi_secrets.data["unifi.networks.guest.wlan.passphrase"])
  pmf_mode                  = "optional"
  security                  = "wpapsk"
  site                      = unifi_site.default.name
  user_group_id             = data.unifi_user_group.default.id
  wlan_band                 = "both"
}