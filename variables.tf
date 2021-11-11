variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })
}

variable "expose_services" {
  description = "Expose ECLWatch and ELK to the Internet. This is not secure. Please consider before using it."
  type        = bool
  default     = false
}

variable "auto_launch_eclwatch" {
  description = "Auto launch ELCWatch after each connection to the cluster."
  type        = bool
  default     = false
}

variable "auto_connect" {
  description = "Automatically connect to the Kubernetes cluster from the host machine by overwriting the current context."
  type        = bool
  default     = false
}

variable "disable_helm" {
  description = "Disable Helm deployments by Terraform."
  type        = bool
  default     = false
}

variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Metadata module variables."
  type = object({
    market              = string
    sre_team            = string
    environment         = string
    product_name        = string
    business_unit       = string
    product_group       = string
    subscription_type   = string
    resource_group_type = string
    project             = string
  })

  default = {
    business_unit       = ""
    environment         = ""
    market              = ""
    product_group       = ""
    product_name        = "hpcc"
    project             = ""
    resource_group_type = ""
    sre_team            = ""
    subscription_type   = ""
  }
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)

  default = {
    "" = ""
  }
}

variable "resource_group" {
  description = "Resource group module variables."
  type        = any

  default = {
    unique_name = true
    location    = null
  }
}

variable "virtual_network" {
  description = "Virtual network attributes."
  type        = any
  default     = null
}

variable "node_pools" {
  description = "node pools"
  type        = any # top level keys are node pool names, sub-keys are subset of node_pool_defaults keys
  default     = { default = {} }
}

variable "image_root" {
  description = "Root of the image other than hpccsystems."
  type        = string
  default     = null
}

variable "image_name" {
  description = "Root of the image other than hpccsystems."
  type        = string
  default     = null
}

variable "image_version" {
  description = "Root of the image other than hpccsystems."
  type        = string
  default     = null
}

variable "hpcc" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = { default = { name = "myhpcck8s" } }
}

variable "storage" {
  description = "Storage account arguments."
  type        = any
  default     = { default = {} }
}

variable "existing_storage" {
  description = "Existing storage account metadata."
  type        = any
  default     = { default = {} }
}

variable "elk" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = { default = { name = "myhpccelk", enable = true } }
}
