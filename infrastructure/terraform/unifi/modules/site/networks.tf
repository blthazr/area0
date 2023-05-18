# UniFi Networks
resource "unifi_network" "network" {
  for_each = { for network_id, network in var.networks : network_id => network }

  dhcp_dns                     = each.value.dhcp_dns
  dhcp_enabled                 = each.value.dhcp_enabled
  dhcp_lease                   = each.value.dhcp_lease
  dhcp_start                   = each.value.dhcp_start
  dhcp_stop                    = each.value.dhcp_stop
  dhcp_v6_dns                  = each.value.dhcp_v6_dns
  dhcp_v6_dns_auto             = each.value.dhcp_v6_dns_auto
  dhcp_v6_enabled              = each.value.dhcp_v6_enabled
  dhcp_v6_lease                = each.value.dhcp_v6_lease
  dhcp_v6_start                = each.value.dhcp_v6_start
  dhcp_v6_stop                 = each.value.dhcp_v6_stop
  domain_name                  = each.value.domain_name
  igmp_snooping                = each.value.igmp_snooping
  internet_access_enabled      = each.value.internet_access_enabled
  intra_network_access_enabled = each.value.intra_network_access_enabled
  ipv6_interface_type          = each.value.ipv6_interface_type
  ipv6_ra_preferred_lifetime   = each.value.ipv6_ra_preferred_lifetime
  ipv6_ra_valid_lifetime       = each.value.ipv6_ra_valid_lifetime
  multicast_dns                = each.value.multicast_dns
  name                         = try(each.value.name, title(replace(each.key, "_", " ")))
  network_group                = each.value.network_group
  purpose                      = each.value.purpose
  site                         = unifi_site.site.name
  subnet                       = each.value.subnet
  vlan_id                      = each.value.vlan
  wan_dns                      = each.value.wan_dns
  wan_egress_qos               = each.value.wan_egress_qos
  wan_networkgroup             = each.value.wan_networkgroup
  wan_type                     = each.value.wan_type
  wan_type_v6                  = each.value.wan_type_v6

  lifecycle {
    ignore_changes = [
      # https://github.com/paultyng/terraform-provider-unifi/issues/196
      ipv6_pd_start,
      ipv6_pd_stop
    ]
  }
}
