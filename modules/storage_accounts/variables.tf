variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })

  validation {
    condition = try(
      regex("hpccdemo", var.admin.name) != "hpccdemo", true
      ) && try(
      regex("hpccdemo", var.admin.email) != "hpccdemo", true
      ) && try(
      regex("@example.com", var.admin.email) != "@example.com", true
    )
    error_message = "Your name and email are required in the admin block and must not contain hpccdemo or @example.com."
  }
}

variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Names"
  type        = map(string)
}

variable "resource_group" {
  description = "Resource group module variables."
  type        = any

  default = {
    unique_name = true
    location    = null
  }
}

variable "storage_accounts" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "virtual_network" {
  description = "Subnet IDs"
  type        = any
  default     = {}
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges"
  type        = map(string)
  default     = {}
}

variable "use_authorized_ip_ranges_only" {
  description = "Should Terraform only use the provided IPs for authorization?"
  type        = bool
  default     = false
}