variable "naming_rules" {
  description = "Naming convention rules."
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "names" {
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
