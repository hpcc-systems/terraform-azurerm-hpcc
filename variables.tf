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

variable "expose_services" {
  description = "Expose ECLWatch and elastic4hpcclogs to the Internet. This is not secure. Please consider before using it."
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

variable "hpcc" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = { name = "myhpcck8s" }
}

variable "storage" {
  description = "Storage account arguments."
  type        = any
  default     = { default = false }
}

variable "elastic4hpcclogs" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = { name = "myelastic4hpcclogs", enable = true }
}

variable "registry" {
  description = "Use if image is hosted on a private docker repository."
  type        = any
  default     = {}
}

# variable "subscription_id" {
#   type        = string
#   description = "Subscription id"
# }

variable "runbook" {
  description = "Information to configure multiple runbooks"
  type = list(object({
    runbook_name = optional(string, "aks_startstop_runbook") # name of the runbook
    runbook_type = optional(string, "PowerShell")            # type of the runbook
    script_name  = optional(string, "start_stop.ps1")        # desired content of the runbook
  }))

  default = [{}]
}

variable "aks_automation" {
  description = "Arguments to automate the Azure Kubernetes Cluster"
  type = object({
    automation_account_name       = string
    local_authentication_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, false)

    schedule = list(object({
      description     = optional(string, "Stop the Kubernetes cluster.")
      schedule_name   = optional(string, "aks_stop")
      runbook_name    = optional(string, "aks_startstop_runbook") # name of the runbook
      frequency       = string
      interval        = string
      start_time      = string
      week_days       = list(string)
      operation       = optional(string, "stop")
      daylight_saving = optional(bool, false)
    }))
  })
}


variable "timezone" {
  description = "Name of timezone"
  type        = string
  default     = "America/New_York"
}

variable "sku_name" {
  description = "The SKU of the account"
  type        = string
  default     = "Basic"
}

variable "log_verbose" {
  description = "Verbose log option."
  type        = string
  default     = "true"
}

variable "log_progress" {
  description = "Progress log option."
  type        = string
  default     = "true"
}
