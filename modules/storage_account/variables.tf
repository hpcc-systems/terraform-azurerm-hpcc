variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })
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

variable "storage" {
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
