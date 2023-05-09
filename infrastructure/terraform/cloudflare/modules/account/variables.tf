variable "account_name" {
  description = "The name of the account that is displayed in the Cloudflare dashboard."
  type        = string
}

variable "account_enforce_twofactor" {
  default     = false
  description = "2FA is enforced on the account."
  type        = bool
}

variable "account_type" {
  default     = "standard"
  description = ""
  type        = string
  validation {
    condition     = contains(["enterprise", "standard"], var.account_type)
    error_message = "Supported account types are 'enterprise', 'standard'."
  }
}
