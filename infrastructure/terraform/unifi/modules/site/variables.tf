variable "ap_groups" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi AP Groups.

    [optional]
      name (string):
        The name of the AP group.
  DOC
  type = map(object({
    name = optional(string, null)
  }))
}

variable "clients" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi clients.

    [optional]
      allow_existing (boolean):
        If terraform should just take over control of an existing client.
      blocked (boolean):
        If client should be blocked from the network.
      fqdn (string):
        Local DNS record for the client.
      ip_address (string):
        An IPv4 address for the client.
      mac (string):
        The MAC address of the client.
      name (string):
        The name of the client.
      network (string):
        The key name of the network of the client.
      network_id (string):
        The network ID of the client.
      note (string):
        A note with additional information for the client. Represented as `alias` in UniFi.
      skip_forget_on_destroy (boolean):
        If the UniFi controller should forget the client on destroy.
      unifi_device_fingerprint_id (number):
        The UniFi device fingerprint of the client.
  DOC

  type = map(object({
    allow_existing              = optional(bool, true)
    blocked                     = optional(bool, false)
    fqdn                        = optional(string)
    ip_address                  = optional(string)
    mac                         = optional(string)
    name                        = optional(string, null)
    network                     = optional(string)
    network_id                  = optional(string)
    note                        = optional(string, null)
    skip_forget_on_destroy      = optional(bool, true)
    unifi_device_fingerprint_id = optional(number, null)
  }))
  validation {
    condition     = alltrue([for client in var.clients : client.network != null || client.network_id != null if client.ip_address != null])
    error_message = "`network` or `network_id` must be specified when `ip_address` is used."
  }
}

variable "devices" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi devices.

    [optional]
    allow_adoption (boolean):
      Adopt the device on apply.
    forget_on_destroy (boolean):
      Forget the device on destroy.
    mac (string):
      The MAC address of the device.
    name (string):
      The name of the device.
    ports (map(object)):
      aggregate_ports (number):
        Number of ports in the aggregate.
      mode (string):
        Operating mode of the port.
        Supported values: `switch`, `mirror`, `aggregate`.
      name (string):
        Human-readable name of the port.
      port_profile (string):
        The key name of the port profile of the port.
      port_profile_id (string):
        The Port Profile ID used of the port.
  DOC
  type = map(object({
    allow_adoption    = optional(bool, true)
    forget_on_destroy = optional(bool, false)
    mac               = optional(string, null)
    name              = optional(string, null)
    ports = optional(map(object({
      aggregate_ports = optional(number)
      mode            = optional(string, "switch")
      name            = optional(string, null)
      port_profile    = optional(string, null)
      port_profile_id = optional(string, null)
    })))
  }))
}

variable "gateways" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi Security Gateways.

    [optional]
      dhcp_relay_servers (list of string):
        The DHCP relay servers.
      log (object):
        guest (boolean):
          Guest firewall log is enabled.
        lan (boolean):
          LAN firewall log is enabled.
        wan (boolean):
          WAN firewall log is enabled.
  DOC
  type = map(object({
    dhcp_relay_servers = optional(list(string), [])
    log = optional(object({
      guest = optional(bool, false)
      lan   = optional(bool, false)
      wan   = optional(bool, false)
    }), {})
  }))
}

variable "name" {
  default     = "Default"
  description = "The description of the site."
  type        = string
}

variable "networks" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi networks.

    [optional]
      dhcp_dns (list of strings):
        Specifies the IPv4 addresses for the DNS server to be returned from the DHCP server.
      dhcp_enabled (boolean):
        Specifies whether DHCP is enabled or not on the network.
      dhcp_lease (number):
        Specifies the lease time for DHCP addresses in seconds.
      dhcp_start (string):
        The IPv4 address where the DHCP range of addresses starts.
      dhcp_stop (string):
        The IPv4 address where the DHCP range of addresses stops.
      dhcp_v6_dns (list of strings):
        Specifies the IPv6 addresses for the DNS server to be returned from the DHCP server.
      dhcp_v6_dns_auto (boolean):
        Specifies DNS source to propagate.
        If set to false the entries in dhcp_v6_dns are used, otherwise the upstream entries are used.
      dhcp_v6_enabled (boolean):
        Enable stateful DHCPv6 for static configuration.
      dhcp_v6_lease (number):
        Specifies the lease time for DHCPv6 addresses in seconds.
      dhcp_v6_start (string):
        Start address of the DHCPv6 range.
      dhcp_v6_stop (string):
        End address of the DHCPv6 range.
      domain_name (string):
        The domain name of the network.
      igmp_snooping (boolean):
        Specifies whether IGMP snooping is enabled or not.
      internet_access_enabled (boolean):
        Specifies whether the network should be allowed to access the internet or not.
      intra_network_access_enabled (boolean):
        Specifies whether the network should be allowed to access other local networks or not.
      ipv6_interface_type (string):
        Specifies which type of IPv6 connection to use.
        Supported values: `static`, `pd`, `none`.
      ipv6_ra_preferred_lifetime (number):
        Lifetime in which the address can be used.
        Address becomes deprecated afterwards.
        Must be lower than or equal to 'ipv6_ra_valid_lifetime'.
      ipv6_ra_valid_lifetime (number):
        Total lifetime in which the address can be used.
        Must be equal to or greater than 'ipv6_ra_preferred_lifetime'.
      multicast_dns (boolean):
        Specifies whether Multicast DNS (mDNS) is enabled or not on the network.
      name (string):
        The name of the network.
      network_group (string):
        The group of the network.
      purpose (string):
        The purpose of the network.
        Supported values: `corporate`, `guest`, `wan`, `vlan-only`.
      subnet (string):
        The subnet of the network. Must be a valid CIDR address.
      vlan (number):
        The VLAN ID of the network.
      wan_dns (list of strings):
        DNS server(s) IP(s) of the WAN.
      wan_egress_qos (number):
        Specifies the WAN egress quality of service.
      wan_networkgroup (string):
        Specifies the WAN network group.
        Supported values: `WAN`, `WAN2`,  `WAN_LTE_FAILOVER`.
      wan_type (string):
        Specifies the IPV4 WAN connection type.
        Supported values: `disabled`, `static`, `dhcp`, `pppoe`.
      wan_type_v6 (string):
        Specifies the IPV6 WAN connection type.
        Supported values: `disabled`, `static`, `dhcpv6`.

      wifi (object):
        ap_group_ids (set of strings):
          The AP group IDs for the WLAN.
        band (string):
          Radio band that the AP's will use.
          Supported values: `both`, `2g`, `5g`.
        bss_transition (boolean):
          Improves client transitions between APs when they have a weak signal.
        fast_roaming (boolean):
          Enables 802.11r fast roaming.
        guest (boolean):
          Use guest network behaviors.
        hide_ssid (boolean):
          Hide SSID from being broadcast.
        l2_isolation (boolean):
          Isolates stations on layer 2 (ethernet) level.
        minimum_data_rate_2g_kbps (number):
          Set minimum data rate control for 2G devices, in Kbps.
          Use 0 to disable minimum data rates.
          Supported values: `0`, `1000`, `2000`, `5500`, `6000`, `9000`, `11000`, `12000`, `18000`, `24000`, `36000`, `48000`, `54000`.
        minimum_data_rate_5g_kbps (number):
          Set minimum data rate control for 5G devices, in Kbps.
          Use 0 to disable minimum data rates.
          Supported values: `0`, `6000`, `9000`, `12000`, `18000`, `24000`, `36000`, `48000`, `54000`.
        multicast_enhancement (boolean):
          Enable Multicast Enhance for the WLAN.
        no2ghz_oui (boolean):
          Connect high performance clients to 5 GHz only.
        passphrase (string):
          The security passphrase for the WLAN.
        pmf_mode (string):
          Enable Protected Management Frames.
        proxy_arp (boolean):
          Reduces airtime usage by allowing APs to "proxy" common broadcast frames as unicast.
        security (string):
          The type of WiFi security for the WLAN.
          Supported values: `wpapsk`, `wpaeap`, `open`.
        ssid (string):
          The SSID of the network.
        user_group (string):
          The key name of the user group for the WLAN.
        wpa3_support (boolean):
          Enable WPA3 support.
        wpa3_transition (boolean):
          Enable WPA3 and WPA2 support.
  DOC
  type = map(object({
    dhcp_dns                     = optional(list(string), [])
    dhcp_enabled                 = optional(bool, null)
    dhcp_lease                   = optional(number, 86400)
    dhcp_start                   = optional(string, null)
    dhcp_stop                    = optional(string, null)
    dhcp_v6_dns                  = optional(list(string), [])
    dhcp_v6_dns_auto             = optional(bool, true)
    dhcp_v6_enabled              = optional(bool, false)
    dhcp_v6_lease                = optional(number, 86400)
    dhcp_v6_start                = optional(string, null)
    dhcp_v6_stop                 = optional(string, null)
    domain_name                  = optional(string, null)
    igmp_snooping                = optional(bool, false)
    internet_access_enabled      = optional(bool, true)
    intra_network_access_enabled = optional(bool, true)
    ipv6_interface_type          = optional(string, "none")
    ipv6_ra_preferred_lifetime   = optional(number, 14400)
    ipv6_ra_valid_lifetime       = optional(number, 86400)
    multicast_dns                = optional(bool, null)
    name                         = optional(string, null)
    network_group                = optional(string, "LAN")
    purpose                      = optional(string, "corporate")
    subnet                       = optional(string, null)
    vlan                         = optional(number, null)
    wan_dns                      = optional(list(string), [])
    wan_egress_qos               = optional(number, 0)
    wan_networkgroup             = optional(string, null)
    wan_type                     = optional(string, null)
    wan_type_v6                  = optional(string, null)
    wifi = optional(object({
      ap_group_ids              = optional(list(string), [])
      band                      = optional(string, "both")
      bss_transition            = optional(bool, true)
      fast_roaming              = optional(bool, false)
      guest                     = optional(bool)
      hide_ssid                 = optional(bool, false)
      l2_isolation              = optional(bool, false)
      minimum_data_rate_2g_kbps = optional(number, 0)
      minimum_data_rate_5g_kbps = optional(number, 0)
      multicast_enhancement     = optional(bool, false)
      no2ghz_oui                = optional(bool, true)
      passphrase                = optional(string)
      pmf_mode                  = optional(string, "disabled")
      proxy_arp                 = optional(bool, false)
      security                  = optional(string, "open")
      ssid                      = optional(string)
      user_group                = optional(string, "default")
      wpa3_support              = optional(bool, false)
      wpa3_transition           = optional(bool, false)
    }))
  }))
  validation {
    condition     = alltrue([for network in var.networks : contains(["static", "pd", "none"], network.ipv6_interface_type)])
    error_message = "Supported values are 'static', 'pd', 'none'."
  }
  validation {
    condition     = alltrue([for network in var.networks : network.ipv6_ra_preferred_lifetime <= network.ipv6_ra_valid_lifetime])
    error_message = "[ ipv6_ra_preferred_lifetime ] Value must be less than or equal to `ipv6_ra_valid_lifetime`."
  }
  validation {
    condition     = alltrue([for network in var.networks : network.ipv6_ra_valid_lifetime >= network.ipv6_ra_preferred_lifetime])
    error_message = "[ ipv6_ra_valid_lifetime ] Value must be greater than or equal to `ipv6_ra_preferred_lifetime`."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["corporate", "guest", "wan", "vlan-only"], network.purpose)])
    error_message = "[ purpose ] Supported values are 'corporate', 'guest', 'wan', 'vlan-only'."
  }
  validation {
    condition     = alltrue([for network in var.networks : can(cidrhost(network.subnet, 0)) && can(cidrnetmask(network.subnet)) || network.subnet == null])
    error_message = "[ subnet ] The subnet must be an IP address in CIDR notation."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["WAN", "WAN2", "WAN_LTE_FAILOVER"], network.wan_networkgroup) if network.purpose == "wan"])
    error_message = "[ wan_networkgroup ] Supported values are 'WAN', 'WAN2', 'WAN_LTE_FAILOVER'."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["disabled", "static", "dhcp", "pppoe"], network.wan_type) if network.purpose == "wan"])
    error_message = "[ wan_type ] Supported values are 'disabled', 'static', 'dhcp', 'pppoe'."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["disabled", "static", "dhcpv6"], network.wan_type_v6) if network.purpose == "wan"])
    error_message = "[ wan_type_v6 ] Supported values are 'disabled', 'static', 'dhcpv6'."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["both", "2g", "5g"], network.wifi.band) if network.wifi != null])
    error_message = "[ band ] Supported values are 'both', '2g', '5g'."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains([0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000], network.wifi.minimum_data_rate_2g_kbps) if network.wifi != null])
    error_message = "[ minimum_data_rate_2g_kbps ] Supported values are 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains([0, 6000, 9000, 12000, 18000, 24000, 36000, 48000, 54000], network.wifi.minimum_data_rate_5g_kbps) if network.wifi != null])
    error_message = "[ minimum_data_rate_5g_kbps ] Supported values are 0, 6000, 9000, 12000, 18000, 24000, 36000, 48000, 54000."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["required", "optional", "disabled"], network.wifi.pmf_mode) if network.wifi != null])
    error_message = "[ pmf_mode ] Supported values are 'required', 'optional', 'disabled'."
  }
  validation {
    condition     = alltrue([for network in var.networks : contains(["wpapsk", "wpaeap", "open"], network.wifi.security) if network.wifi != null])
    error_message = "[ security ] Supported values are 'wpapsk', 'wpaeap', 'open'."
  }
}

variable "port_forward" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi Firewall Port Forwarding.

    [optional]
    dst_port (string):
      The destination port for the forwarding.
    fwd_ip (string):
      The IPv4 address to forward traffic to.
    fwd_port (string):
      The port to forward traffic to.
    log (boolean):
      Enable forwarded traffic logging.
    name (string):
      The name of the port forwarding rule.
    port_forward_interface (string):
      The port forwarding interface.
      Supported values: `wan`, `wan2`, `both`.
    protocol (string):
      The protocol for the port forwarding rule.
      Supported values: `tcp`, `udp`, `tcp_udp`.
    src_ip (string):
      The source IPv4 address (or CIDR) of the port forwarding rule.
  DOC
  type = map(object({
    dst_port               = optional(string)
    fwd_ip                 = optional(string)
    fwd_port               = optional(string)
    log                    = optional(bool, false)
    name                   = optional(string, null)
    port_forward_interface = optional(string)
    protocol               = optional(string, "tcp_udp")
    src_ip                 = optional(string, "any")
  }))
  validation {
    condition     = alltrue([for rule in var.port_forward : contains(["wan", "wan2", "both"], rule.port_forward_interface)])
    error_message = "[ port_forward_interface ] Supported values are 'wan', 'wan2', 'both'."
  }
  validation {
    condition     = alltrue([for rule in var.port_forward : contains(["tcp", "udp", "tcp_udp"], rule.protocol)])
    error_message = "[ protocol ] Supported values are 'tcp', 'udp', 'tcp_udp'."
  }
}

variable "port_profiles" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi Port Profiles.

    [optional]
    autoneg (boolean):
      Enable link auto negotiation for the port profile.
    dot1x_ctrl (string):
      The type of 802.1X control to use.
      Supported values: `auto`, `force_authorized`, `force_unauthorized`, `mac_based`, `multi_host`.
    dot1x_idle_timeout (number):
      The timeout, in seconds, to use when using the MAC Based 802.1X control.
      Supported values: 0-65535.
    egress_rate_limit_kbps (number):
      The egress rate limit, in kbps, for the port profile.
      Supported values: 64-9999999.
    egress_rate_limit_kbps_enabled (boolean):
      Enable egress rate limiting for the port profile.
    forward (string):
      The type forwarding to use for the port profile.
    full_duplex (boolean):
      Enable full duplex for the port profile.
    isolation (boolean):
      Enable port isolation for the port profile.
    lldpmed_enabled (boolean):
      Enable LLDP-MED for the port profile.
    name (string):
      The name of the port profile.
    op_mode (string):
      The operation mode for the port profile.
      Supported values: `switch`
    port_security_enabled (boolean):
      Enable port security for the port profile.
    stormctrl_bcast_enabled (boolean):
      Enable broadcast Storm Control for the port profile.
    stormctrl_mcast_enabled (boolean):
      Enable multicast Storm Control for the port profile.
    stormctrl_ucast_enabled (boolean):
      Enable unknown unicast Storm Control for the port profile.
    stp_port_mode (boolean):
      Enable spanning tree protocol on the port profile.
  DOC
  type = map(object({
    autoneg                        = optional(bool, true)
    dot1x_ctrl                     = optional(string, "force_authorized")
    dot1x_idle_timeout             = optional(number, 300)
    egress_rate_limit_kbps         = optional(number)
    egress_rate_limit_kbps_enabled = optional(bool, false)
    forward                        = optional(string, "native")
    full_duplex                    = optional(bool, false)
    isolation                      = optional(bool, false)
    lldpmed_enabled                = optional(bool, true)
    name                           = optional(string, null)
    op_mode                        = optional(string, "switch")
    port_security_enabled          = optional(bool, false)
    stormctrl_bcast_enabled        = optional(bool, false)
    stormctrl_mcast_enabled        = optional(bool, false)
    stormctrl_ucast_enabled        = optional(bool, false)
    stp_port_mode                  = optional(bool, true)
  }))
  validation {
    condition     = alltrue([for port_profile in var.port_profiles : contains(["auto", "force_authorized", "force_unauthorized", "mac_based", "multi_host"], port_profile.dot1x_ctrl)])
    error_message = "[ dot1x_ctrl ] Supported values are 'auto', 'force_authorized', 'force_unauthorized', 'mac_based', 'multi_host'."
  }
  validation {
    condition     = alltrue([for port_profile in var.port_profiles : port_profile.dot1x_idle_timeout >= 0 && port_profile.dot1x_idle_timeout <= 65535])
    error_message = "[ dot1x_idle_timeout ] Supported values are between 0 and 65535."
  }
  validation {
    condition     = alltrue([for port_profile in var.port_profiles : port_profile.egress_rate_limit_kbps != null if port_profile.egress_rate_limit_kbps_enabled == true])
    error_message = "[ egress_rate_limit_kbps ] A value must be set when `egress_rate_limit_kbps_enabled` is true."
  }
  validation {
    condition     = alltrue([for port_profile in var.port_profiles : port_profile.egress_rate_limit_kbps >= 64 && port_profile.egress_rate_limit_kbps <= 9999999 if port_profile.egress_rate_limit_kbps_enabled == true && port_profile.egress_rate_limit_kbps != null])
    error_message = "[ egress_rate_limit_kbps ] Supported values are between 64 and 9999999."
  }
  validation {
    condition     = alltrue([for port_profile in var.port_profiles : contains(["all", "native", "customize", "disabled"], port_profile.forward)])
    error_message = "[ forward ] Supported values are 'all', 'native', 'customize', 'disabled'."
  }
  validation {
    condition     = alltrue([for port_profile in var.port_profiles : contains(["switch"], port_profile.op_mode)])
    error_message = "[ op_mode ] Supported values are 'switch'."
  }
}

variable "secrets" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi secrets.

    [optional]
  DOC
  type        = any
}

variable "user_groups" {
  default     = {}
  description = <<-DOC
    A map of objects containing UniFi User Groups.

    [optional]
      name (string):
        The name of the user group.
      qos_rate_max_down (number):
        The QOS maximum download rate.
      qos_rate_max_up (number):
        The QOS maximum upload rate.
  DOC
  type = map(object({
    name              = optional(string, null)
    qos_rate_max_down = optional(number, -1)
    qos_rate_max_up   = optional(number, -1)
  }))
}
