locals {
  clients     = yamldecode(file("./clients.yaml"))
  devices     = yamldecode(file("./devices.yaml"))
  domain_name = nonsensitive(data.sops_file.unifi_secrets.data["unifi.domain_name"])
  networks    = yamldecode(file("./networks.yaml"))
}
