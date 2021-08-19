variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })
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

variable "disable_kubernetes" {
  description = "Gracefully shut the Kubernetes cluster down."
  type        = bool
  default     = false
}

variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "enable_nginx" {
  description = "Enable NGINX ingress controler."
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
  type = object({
    unique_name = bool
    location    = string
  })

  default = {
    unique_name = true
    location    = null
  }
}

variable "system_node_pool" {
  description = "Kubernetes system node pool variables."
  type = object({
    vm_size    = string
    node_count = number
  })
}

variable "additional_node_pool" {
  description = "Kubernetes user node pool variables."
  type = object({
    vm_size             = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  })

  default = {
    enable_auto_scaling = true
    max_count           = 0
    min_count           = 0
    vm_size             = ""
  }
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
  type = object({
    chart     = string
    namespace = string
    name      = string
    values    = list(string)
    version   = string
  })

  default = {
    chart     = null
    name      = "myhpcck8s"
    namespace = "default"
    values    = []
    version   = null
  }
}

variable "storage" {
  description = "HPCC Helm chart variables."
  type = object({
    disable_storage_account = bool
    account_kind            = string
    replication_type        = string
    account_tier            = string
    access_tier             = string
    chart                   = string
    enable_large_file_share = bool
    enable_static_website   = bool
    values                  = list(string)
  })

  default = {
    access_tier             = "Hot"
    account_kind            = "StorageV2"
    account_tier            = "Premium"
    chart                   = null
    disable_storage_account = true
    enable_large_file_share = false
    enable_static_website   = true
    replication_type        = "LRS"
    values                  = []
  }
}

variable "elk" {
  description = "HPCC Helm chart variables."
  type = object({
    enable = bool
    name   = string
    chart  = string
    values = list(string)
  })

  default = {
    enable = true
    name   = "myhpccelk"
    chart  = null
    values = []
  }
}
