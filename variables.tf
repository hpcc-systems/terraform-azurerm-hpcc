variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })
}

variable "naming_conventions_enabled" {
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

  default = {
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }
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
    vm_size             = "Standard_D2s_v3"
  }
}

variable "hpcc_image" {
  description = "HPCC image variables."
  type = object({
    version = string
    root    = string
    name    = string
  })

  default = {
    name    = "platform-core"
    root    = "hpccsystems"
    version = "latest"
  }
}


variable "use_local_charts" {
  description = "Use local charts instead of remote."
  type        = bool
  default     = false
}

variable "hpcc_helm" {
  description = "HPCC helm chart variables."
  type = object({
    local_chart   = string
    chart_version = string
    namespace     = string
    name          = string
    values        = list(string)
  })

  default = {
    chart_version = null
    local_chart   = null
    name          = "myhpcck8s"
    namespace     = "default"
    values        = []
  }
}

variable "hpcc_storage" {
  description = "HPCC helm chart variables."
  type = object({
    values = list(string)
  })
  default = {
    values = []
  }
}

variable "hpcc_elk" {
  description = "HPCC helm chart variables."
  type = object({
    enabled = bool
    name    = string
    values  = list(string)
  })

  default = {
    enabled = true
    name    = "myhpccelk"
    values  = []
  }
}
