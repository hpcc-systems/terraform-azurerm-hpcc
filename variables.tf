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
  type = object({
    name                       = optional(string, "myhpcck8s")
    version                    = optional(string)
    chart                      = optional(string, "hpcc")
    remote_chart               = optional(string)
    local_chart                = optional(string)
    create_namespace           = optional(bool, true)
    namespace                  = optional(string, "default")
    atomic                     = optional(bool, false)
    recreate_pods              = optional(bool, false)
    reuse_values               = optional(bool, false)
    reset_values               = optional(bool, false)
    force_update               = optional(bool, false)
    cleanup_on_fail            = optional(bool, false)
    disable_openapi_validation = optional(bool, false)
    max_history                = optional(number, 0)
    wait                       = optional(bool, true)
    dependency_update          = optional(bool, false)
    timeout                    = optional(number, 480)
    wait_for_jobs              = optional(bool, false)
    lint                       = optional(bool, false)
    values                     = optional(list(string), [])
    image_name                 = optional(string)
    image_root                 = optional(string)
    image_version              = optional(string)
    expose_eclwatch            = optional(bool, true)
  })
  default = null
}

variable "storage" {
  description = "Storage account arguments."
  type = object({
    name                       = optional(string, "azstorage")
    chart                      = optional(string, "hpcc-azurefile")
    version                    = optional(string)
    remote_chart               = optional(string)
    local_chart                = optional(string)
    values                     = optional(list(string), [])
    atomic                     = optional(bool, false)
    force_update               = optional(bool, false)
    recreate_pods              = optional(bool, false)
    reuse_values               = optional(bool, false)
    reset_values               = optional(bool, false)
    cleanup_on_fail            = optional(bool, false)
    disable_openapi_validation = optional(bool, false)
    max_history                = optional(number, 0)
    wait                       = optional(bool, true)
    dependency_update          = optional(bool, false)
    timeout                    = optional(number, 600)
    wait_for_jobs              = optional(bool, false)
    lint                       = optional(bool, false)
    default                    = optional(bool, false)
    namespace                  = optional(string, "default")
    create_namespace           = optional(bool, true)
  })
  default = null
}

variable "elastic4hpcclogs" {
  description = "HPCC Helm chart variables."
  type = object({
    name                       = optional(string, "myelastic4hpcclogs")
    namespace                  = optional(string, "default")
    chart                      = optional(string, "elastic4hpcclogs")
    remote_chart               = optional(string)
    local_chart                = optional(string)
    version                    = optional(string)
    values                     = optional(list(string), [])
    create_namespace           = optional(bool, true)
    atomic                     = optional(bool, false)
    force_update               = optional(bool, false)
    recreate_pods              = optional(bool, false)
    reuse_values               = optional(bool, false)
    reset_values               = optional(bool, false)
    cleanup_on_fail            = optional(bool, false)
    disable_openapi_validation = optional(bool, false)
    wait                       = optional(bool, true)
    max_history                = optional(number, 0)
    dependency_update          = optional(bool, false)
    timeout                    = optional(number, 300)
    wait_for_jobs              = optional(bool, false)
    lint                       = optional(bool, false)
    enable                     = optional(bool, false)
    expose                     = optional(bool, false)
  })
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
    create_new_account            = optional(bool, false)
    create_new_role_assignment    = optional(bool, false)
    automation_account_name       = optional(string, "aks-automation-default")
    resource_group_name           = optional(string, "aa-us-hpccplatform-dev-eastus")
    local_authentication_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, false)

    schedule = list(object({
      description     = optional(string, "Stop the Kubernetes cluster.")
      schedule_name   = optional(string, "aks_stop")
      runbook_name    = optional(string, "aks_startstop_runbook") # name of the runbook
      frequency       = string
      interval        = string
      start_time      = string
      timezone        = optional(string, "America/New_York")
      week_days       = list(string)
      operation       = optional(string, "stop")
      daylight_saving = optional(bool, false)
    }))
  })
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

variable "identity_type" {
  description = "SystemAssigned or UserAssigned."
  type        = string
  default     = "UserAssigned"

  validation {
    condition = (
      var.identity_type == "UserAssigned" ||
      var.identity_type == "SystemAssigned"
    )
    error_message = "Identity must be one of 'SystemAssigned' or 'UserAssigned'."
  }
}

variable "user_assigned_identity" {
  description = "User assigned identity for the managed cluster (leave and the module will create one)."
  type = object({
    id           = string
    principal_id = string
    client_id    = string
  })
  default = null
}

variable "user_assigned_identity_name" {
  description = "Name of user assigned identity to be created (if applicable)."
  type        = string
  default     = null
}

variable "configure_network_role" {
  description = "Add Network Contributor role for identity on input subnets."
  type        = bool
  default     = true
}

variable "sku_tier" {
  description = "Sets the cluster's SKU tier. The paid tier has a financially-backed uptime SLA. Read doc [here](https://docs.microsoft.com/en-us/azure/aks/uptime-sla)."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["free", "paid"], lower(var.sku_tier))
    error_message = "Available SKU Tiers are \"Free\" and \"Paid\"."
  }
}

variable "kubernetes_version" {
  description = "kubernetes version"
  type        = string
  default     = null # defaults to latest recommended version
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster."
  type        = string
  default     = null # null value will create name based on var.names
}

variable "private_cluster_enabled" {
  description = "Private Cluster"
  type        = string
  default     = "false"
}

variable "network_plugin" {
  description = "network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "kubenet"

  validation {
    condition = (
      var.network_plugin == "kubenet" ||
      var.network_plugin == "azure"
    )
    error_message = "Network Plugin must set to kubenet or azure."

  }
}

variable "network_policy" {
  description = "Sets up network policy to be used with Azure CNI."
  type        = string
  default     = null

  validation {
    condition = (
      (var.network_policy == null) ||
      (var.network_policy == "azure") ||
      (var.network_policy == "calico")
    )
    error_message = "Network pollicy must be azure or calico."
  }
}

variable "network_profile_options" {
  description = "docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set"
  type = object({
    docker_bridge_cidr = string
    dns_service_ip     = string
    service_cidr       = string
  })
  default = null

  validation {
    condition = (
      ((var.network_profile_options == null) ? true :
        ((var.network_profile_options.docker_bridge_cidr != null) &&
          (var.network_profile_options.dns_service_ip != null) &&
      (var.network_profile_options.service_cidr != null)))
    )
    error_message = "Incorrect values set. docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set."

  }
}

variable "outbound_type" {
  description = "outbound (egress) routing method which should be used for this Kubernetes Cluster"
  type        = string
  default     = "loadBalancer"
}

variable "pod_cidr" {
  description = "used for pod IP addresses"
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = "Default node pool.  Value refers to key within node_pools variable."
  type        = string
  default     = "system"
}

variable "log_analytics_workspace_id" {
  description = "ID of the Azure Log Analytics Workspace"
  type        = string
  default     = null
}

variable "rbac_admin_object_ids" {
  description = "Admin group object ids for use with rbac active directory integration"
  type        = map(string) # keys are only for documentation purposes
  default     = {}
}

variable "rbac" {
  description = "role based access control settings"
  type = object({
    enabled = optional(bool, false)
    managed = optional(bool, true)
  })
  default = {
    enabled = true
    managed = true
  }
}

variable "node_pool_defaults" {
  description = "node pool defaults"
  type = object({
    vm_size                      = string
    zones                        = list(number)
    node_count                   = number
    auto_scaling_enabled         = bool
    min_count                    = number
    max_count                    = number
    host_encryption_enabled      = bool
    node_public_ip_enabled       = bool
    max_pods                     = number
    node_labels                  = map(string)
    only_critical_addons_enabled = bool
    orchestrator_version         = string
    os_disk_size_gb              = number
    os_disk_type                 = string
    type                         = string
    tags                         = map(string)
    subnet                       = string # must be key from node_pool_subnets variable

    # settings below not available in default node pools
    mode                         = string
    node_taints                  = list(string)
    max_surge                    = string
    eviction_policy              = string
    os_type                      = string
    priority                     = string
    proximity_placement_group_id = string
    spot_max_price               = number
  })
  default = { name = null
    vm_size                      = "Standard_B2s"
    zones                        = [1, 2, 3]
    node_count                   = 1
    auto_scaling_enabled         = false
    min_count                    = null
    max_count                    = null
    host_encryption_enabled      = false
    node_public_ip_enabled       = false
    max_pods                     = null
    node_labels                  = null
    only_critical_addons_enabled = false
    orchestrator_version         = null
    os_disk_size_gb              = null
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    tags                         = null
    subnet                       = null # must be a key from node_pool_subnets variable

    # settings below not available in default node pools
    mode                         = "User"
    node_taints                  = null
    max_surge                    = "1"
    eviction_policy              = null
    os_type                      = "Linux"
    priority                     = "Regular"
    proximity_placement_group_id = null
    spot_max_price               = null
  }
}

variable "azure_policy_enabled" {
  description = "to apply at-scale enforcements and safeguards on your clusters in a centralized, consistent manner"
  type        = bool
  default     = false
}

variable "subscription_id" {
  description = "Subscription id"
  type        = string
}