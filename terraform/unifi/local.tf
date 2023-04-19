locals {
  clients     = yamldecode(file("./clients.yaml"))
  devices     = yamldecode(file("./devices.yaml"))
}
