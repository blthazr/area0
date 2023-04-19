# UniFi AP Groups

data "unifi_ap_group" "default" {
  site = unifi_site.default.name
}
