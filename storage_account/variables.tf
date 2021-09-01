variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Names"
  type        = map(string)
}

variable "storage" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = { default = {} }
}

variable "existing_storage" {
  description = "Existing storage account metadata."
  type        = any
  default     = { default = {} }
}

variable "unique_name" {
  description = "Generate a unique name."
  type        = bool
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}
