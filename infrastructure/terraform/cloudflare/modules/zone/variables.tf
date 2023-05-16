variable "account_id" {
  description = "The account id used to manage the zone"
  type        = string
}

variable "dns_records" {
  default     = []
  description = <<-DOC
    A list of maps containing Cloudflare dns records.

    [required]
      name (string):
        The name of the record.

    [optional]
      allow_overwrite (boolean):
        Allow creation of this record in Terraform to overwrite an existing record, if any.
      comment (string):
        Comments or notes about the DNS record.
      id (string):
        Unique identifier used for organizing dns records. Internal use only.
      priority (number):
        The priority of the record.
      proxied (boolean):
        Whether the record gets Cloudflare's origin protection.
      ttl (number):
        The TTL of the record.
      type (string):
        The type of the record.
        Supported record types: 'A', 'AAAA', 'CAA', 'CNAME', 'TXT', 'SRV', 'LOC', 'MX', 'NS', 'SPF', 'CERT', 'DNSKEY', 'DS', 'NAPTR', 'SMIMEA', 'SSHFP', 'TLSA', 'URI', 'PTR', 'HTTPS'.
      value (string):
  DOC
  type = list(object({
    allow_overwrite = optional(bool, false)
    comment         = optional(string, null)
    id              = optional(string)
    name            = string
    priority        = optional(number, 0)
    proxied         = optional(bool, true)
    public_address  = optional(bool, false)
    ttl             = optional(number, 1)
    type            = optional(string, "A")
    value           = optional(string, null)
  }))
  validation {
    condition     = alltrue([for record in var.dns_records : contains(["A", "AAAA", "CAA", "CNAME", "TXT", "SRV", "LOC", "MX", "NS", "SPF", "CERT", "DNSKEY", "DS", "NAPTR", "SMIMEA", "SSHFP", "TLSA", "URI", "PTR", "HTTPS"], record.type)])
    error_message = "Supported record types are 'A', 'AAAA', 'CAA', 'CNAME', 'TXT', 'SRV', 'LOC', 'MX', 'NS', 'SPF', 'CERT', 'DNSKEY', 'DS', 'NAPTR', 'SMIMEA', 'SSHFP', 'TLSA', 'URI', 'PTR', 'HTTPS'."
  }
}

variable "firewall_rules" {
  description = <<-DOC
    A list of maps containing Cloudflare firewall rules.

    [required]
      expression (string):
        The filter expression to be used.

    [optional]
      action (string):
        The action to apply to a matched request.
        Supported actions: `block`, `challenge`, `allow`, `js_challenge`, `managed_challenge`, `log`, `bypass`.
      description (string):
        A note that you can use to describe the purpose of the filter and rule.
      paused (boolean):
        Whether this filter is currently paused.
      priority (number):
        The priority of the rule to allow control of processing order.
        A lower number indicates high priority.
        If not provided, any rules with a priority will be sequenced before those without.
      ref (string):
        Short reference tag to quickly select related rules.
  DOC
  default     = null
  type = list(object({
    action      = optional(string, "block")
    description = optional(string, null)
    expression  = string
    paused      = optional(bool, false)
    priority    = optional(number, null)
    ref         = optional(string, null)
  }))
  validation {
    condition     = alltrue([for rule in var.firewall_rules : contains(["block", "challenge", "allow", "js_challenge", "managed_challenge", "log", "bypass"], rule.action)])
    error_message = "Supported record types are 'block', 'challenge', 'allow', 'js_challenge', 'managed_challenge', 'log', 'bypass'."
  }
}

variable "jump_start" {
  default     = null
  description = "Scan for DNS records on creation."
  type        = bool
}

variable "name" {
  description = "The DNS zone name to be managed."
  type        = string
}

variable "page_rules" {
  description = <<-DOC
      A list of maps containing Cloudflare page rules.

      [required]
        target (string):
        The URL pattern to target with the page rule.

      [optional]
        priority (number):
          The priority of the page rule among others for this target.
        status:
          The page rule status. is active or disabled.
          Supported status: `active`, `disabled`.
    DOC
  default     = null
  type = list(object({
    actions = object({
      always_use_https         = optional(bool, false)
      automatic_https_rewrites = optional(string)
      cache_level              = optional(string)
      disable_apps             = optional(bool, false)
      disable_performance      = optional(bool, false)
      disable_railgun          = optional(bool, false)
      disable_security         = optional(bool, false)
      disable_zaraz            = optional(bool, false)
      rocket_loader            = optional(string)
    })
    id       = string
    priority = optional(number, 0)
    status   = optional(string, "active")
    target   = string
  }))
  validation {
    condition     = alltrue([for rule in var.page_rules : contains(["active", "disabled"], rule.status)])
    error_message = "Supported rule status are 'active', 'disabled'."
  }
}

variable "paused" {
  default     = false
  description = "Zone is paused (traffic bypasses Cloudflare)."
  type        = bool
}

variable "plan" {
  default     = "free"
  description = "The name of the commercial plan to apply to the zone."
  type        = string
  validation {
    condition     = contains(["free", "lite", "pro", "pro_plus", "business", "enterprise", "partners_free", "partners_pro", "partners_business", "partners_enterprise"], var.plan)
    error_message = "Supported plans are 'free', 'lite', 'pro', 'pro_plus', 'business', 'enterprise', 'partners_free', 'partners_pro', 'partners_business', 'partners_enterprise'."
  }
}

variable "type" {
  default     = "full"
  description = <<-DOC
    The type of zone configured in Cloudflare.
    A full zone implies that DNS is hosted with Cloudflare.
    A partial zone is typically a partner-hosted zone or a CNAME setup.
  DOC
  type        = string
  validation {
    condition     = contains(["full", "partial"], var.type)
    error_message = "Supported plans are 'full', 'partial'."
  }
}
