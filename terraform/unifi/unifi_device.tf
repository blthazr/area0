# UniFi Devices

resource "unifi_device" "device" {
  for_each          = { for device_id, device in local.devices: device_id => device }

  allow_adoption    = try(each.value.allow_adoption, true)
  forget_on_destroy = try(each.value.forget_on_destroy, false)
  mac               = try(each.value.mac, null)
  name              = try(each.value.name, title(replace(each.key, "_", " ")))
  # port_override     =
  site              = try(each.value.site, unifi_site.default.name)

  lifecycle {
    ignore_changes = [
      port_override
    ]
  }
}
