data "sops_file" "unifi_secrets" {
  source_file = "secret.sops.yaml"
}
