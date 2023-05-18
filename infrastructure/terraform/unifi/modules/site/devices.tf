# UniFi Devices
resource "unifi_device" "device" {
  for_each = { for device_id, device in var.devices : device_id => device }

  allow_adoption    = each.value.allow_adoption
  forget_on_destroy = each.value.forget_on_destroy
  mac               = each.value.mac
  name              = try(each.value.name, title(replace(each.key, "_", " ")))
  site              = unifi_site.site.name

  dynamic "port_override" {
    for_each = { for key, port_conf in each.value.ports != null ? each.value.ports : {} : key => port_conf }

    content {
      aggregate_num_ports = try(port_override.value["aggregate_ports"], 0)
      name                = port_override.value["name"]
      number              = port_override.key
      op_mode             = port_override.value["mode"]
      port_profile_id     = try(local.port_profiles[port_override.value.port_profile].id, try(port_override.value["port_profile_id"], data.unifi_port_profile.all.id))
    }
  }
}

# UniFi Port Profiles
locals {
  port_profiles = merge(
    { for key, value in data.unifi_port_profile.network : "${key}" => value },
    { for key, value in unifi_port_profile.port_profile : "${key}" => value },
    {
      all      = data.unifi_port_profile.all
      disabled = data.unifi_port_profile.disabled
    }
  )
}

data "unifi_port_profile" "all" {
  name = "All"
  site = unifi_site.site.name
}

data "unifi_port_profile" "disabled" {
  name = "Disabled"
  site = unifi_site.site.name
}

data "unifi_port_profile" "network" {
  for_each = { for network_id, network in var.networks : network_id => network if network.purpose != "wan" }

  name = unifi_network.network[each.key].name
  site = unifi_site.site.name
}

resource "unifi_port_profile" "port_profile" {
  for_each = { for profile_id, profile in var.port_profiles : profile_id => profile }

  autoneg                        = each.value.autoneg
  dot1x_ctrl                     = each.value.dot1x_ctrl
  dot1x_idle_timeout             = each.value.dot1x_idle_timeout
  egress_rate_limit_kbps         = each.value.egress_rate_limit_kbps
  egress_rate_limit_kbps_enabled = each.value.egress_rate_limit_kbps_enabled
  forward                        = each.value.forward
  full_duplex                    = each.value.full_duplex
  isolation                      = each.value.isolation
  lldpmed_enabled                = each.value.lldpmed_enabled
  name                           = try(each.value.name, title(replace(each.key, "_", " ")))
  op_mode                        = each.value.op_mode
  port_security_enabled          = each.value.port_security_enabled
  site                           = unifi_site.site.name
  stormctrl_bcast_enabled        = each.value.stormctrl_bcast_enabled
  stormctrl_mcast_enabled        = each.value.stormctrl_mcast_enabled
  stormctrl_ucast_enabled        = each.value.stormctrl_ucast_enabled
  stp_port_mode                  = each.value.stp_port_mode
}
