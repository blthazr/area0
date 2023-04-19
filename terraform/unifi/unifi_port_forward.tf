# UniFi Port Forwarding

resource "unifi_port_forward" "http" {
  dst_port               = 80
  fwd_ip                 = "10.0.100.100"
  fwd_port               = 80
  log                    = true
  name                   = "HTTP"
  port_forward_interface = "wan"
  protocol               = "tcp_udp"
  site                   = unifi_site.default.name
  src_ip                 = "any"
}

resource "unifi_port_forward" "https" {
  dst_port               = 443
  fwd_ip                 = "10.0.100.100"
  fwd_port               = 443
  log                    = true
  name                   = "HTTPS"
  port_forward_interface = "wan"
  protocol               = "tcp_udp"
  site                   = unifi_site.default.name
  src_ip                 = "any"
}

resource "unifi_port_forward" "plex" {
  dst_port               = 32400
  fwd_ip                 = "10.0.100.103"
  fwd_port               = 32400
  log                    = true
  name                   = "Plex Media Server"
  port_forward_interface = "wan"
  protocol               = "tcp_udp"
  site                   = unifi_site.default.name
  src_ip                 = "any"
}
