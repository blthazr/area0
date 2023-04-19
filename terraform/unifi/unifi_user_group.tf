# UniFi User Groups

data "unifi_user_group" "default" {
  site = unifi_site.default.name
}
