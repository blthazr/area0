# UniFi Networks

resource "unifi_network" "network" {
  for_each                     = { for network_id, network in local.networks: network_id => network }

  dhcp_dns                     = try(each.value.dhcp_dns, null)
  dhcp_enabled                 = try(each.value.dhcp_enabled, null)
  dhcp_lease                   = try(each.value.dhcp_lease, 86400)
  dhcp_start                   = try(each.value.dhcp_start, null)
  dhcp_stop                    = try(each.value.dhcp_stop, null)
  dhcp_v6_dns_auto             = try(each.value.dhcp_v6_dns_auto, true)
  dhcp_v6_lease                = try(each.value.dhcp_v6_lease, 86400)
  domain_name                  = try(each.value.domain_name, local.domain_name)
  igmp_snooping                = try(each.value.igmp_snooping, false)
  internet_access_enabled      = try(each.value.internet_access_enabled, true)
  intra_network_access_enabled = try(each.value.intra_network_access_enabled, true)
  ipv6_interface_type          = try(each.value.ipv6_interface_type, "none")
  ipv6_ra_preferred_lifetime   = try(each.value.ipv6_ra_preferred_lifetime, 14400)
  ipv6_ra_valid_lifetime       = try(each.value.ipv6_ra_valid_lifetime, 86400)
  multicast_dns                = try(each.value.multicast_dns, null)
  name                         = each.value.name
  network_group                = try(each.value.network_group, "LAN")
  purpose                      = try(each.value.purpose, "corporate")
  site                         = try(each.value.site, unifi_site.default.name)
  subnet                       = try(each.value.subnet, null)
  vlan_id                      = try(each.value.vlan_id, null)
  wan_dns                      = try(each.value.wan_dns, null)
  wan_gateway                  = try(each.value.wan_gateway, null)
  wan_networkgroup             = try(each.value.wan_networkgroup, null)
  wan_type                     = try(each.value.wan_type, null)
  wan_type_v6                  = try(each.value.wan_type_v6, null)

  lifecycle {
    ignore_changes = [
      # https://github.com/paultyng/terraform-provider-unifi/issues/196
      ipv6_pd_start,
      ipv6_pd_stop
    ]
  }

}
