provider "unifi" {
  username       = data.sops_file.unifi_secrets.data["unifi.api.username"]
  password       = data.sops_file.unifi_secrets.data["unifi.api.password"]
  api_url        = data.sops_file.unifi_secrets.data["unifi.api.url"]
  allow_insecure = data.sops_file.unifi_secrets.data["unifi.api.insecure"]
}
