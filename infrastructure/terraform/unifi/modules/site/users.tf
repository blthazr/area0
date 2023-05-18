# UniFi User Groups
locals {
  user_groups = merge(
    { for key, value in unifi_user_group.user_group : "${key}" => value },
    {
      default = data.unifi_user_group.default
    }
  )
}

data "unifi_user_group" "default" {
  site = unifi_site.site.name
}

resource "unifi_user_group" "user_group" {
  for_each = { for user_group_id, user_group in var.user_groups : user_group_id => user_group }

  name              = try(each.value.name, title(replace(each.key, "_", " ")))
  qos_rate_max_down = each.value.qos_rate_max_down
  qos_rate_max_up   = each.value.qos_rate_max_up
  site              = unifi_site.site.name
}
