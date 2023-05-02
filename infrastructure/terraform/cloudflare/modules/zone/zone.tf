# Cloudflare Zone
resource "cloudflare_zone" "zone" {
  account_id = var.account_id
  jump_start = var.jump_start
  paused     = var.paused
  plan       = var.plan
  type       = var.type
  zone       = var.name
}
