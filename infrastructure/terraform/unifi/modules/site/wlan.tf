# UniFi AP Groups
locals {
  ap_groups = merge(
    { for key, value in data.unifi_ap_group.ap_group : "${key}" => value },
    {
      default = data.unifi_ap_group.default
    }
  )
}

data "unifi_ap_group" "default" {
  site = unifi_site.site.name
}

data "unifi_ap_group" "ap_group" {
  for_each = { for ap_group_id, ap_group in var.ap_groups : ap_group_id => ap_group }

  name = each.value.name
  site = unifi_site.site.name
}

# UniFi Wireless Networks
resource "unifi_wlan" "wlan" {
  for_each = { for network_id, network in var.networks : network_id => network if network.wifi != null }

  ap_group_ids              = [data.unifi_ap_group.default.id]
  bss_transition            = each.value.wifi.bss_transition
  fast_roaming_enabled      = each.value.wifi.fast_roaming
  hide_ssid                 = each.value.wifi.hide_ssid
  is_guest                  = each.value.purpose == "guest" ? true : try(each.value.wifi.guest, false)
  l2_isolation              = each.value.wifi.l2_isolation
  minimum_data_rate_2g_kbps = each.value.wifi.minimum_data_rate_2g_kbps
  minimum_data_rate_5g_kbps = each.value.wifi.minimum_data_rate_5g_kbps
  multicast_enhance         = each.value.wifi.multicast_enhancement
  name                      = each.value.wifi.ssid
  network_id                = unifi_network.network[each.key].id
  no2ghz_oui                = each.value.wifi.no2ghz_oui
  passphrase                = try(var.secrets[unifi_site.site.name].networks[each.key].wifi.passphrase, each.value.wifi.passphrase)
  pmf_mode                  = each.value.wifi.pmf_mode
  proxy_arp                 = each.value.wifi.proxy_arp
  security                  = each.value.wifi.security
  site                      = unifi_site.site.name
  user_group_id             = local.user_groups[each.value.wifi.user_group].id
  wlan_band                 = each.value.wifi.band
  wpa3_support              = each.value.wifi.wpa3_support
  wpa3_transition           = each.value.wifi.wpa3_transition
}
