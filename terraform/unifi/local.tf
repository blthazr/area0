locals {
  devices     = yamldecode(file("./devices.yaml"))
}
