admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

tags = { "justification" = "testing" }

subscription_id = ""

rbac = {
  enabled = false
}

# rbac_admin_object_ids = {
#   "user1" = "value"
# }

identity_type = "UserAssigned"

network_plugin         = "azure"
configure_network_role = true

node_pools = {
  system = {
    vm_size                      = "Standard_D4_v4"
    node_count                   = 1
    auto_scaling_enabled         = true
    only_critical_addons_enabled = true
    min_count                    = 1
    max_count                    = 1
    availability_zones           = []
    subnet                       = "public"
    host_encryption_enabled      = false
    node_public_ip_enabled       = false
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    # max_pods             = 10
    # node_labels          = {"engine" = "roxie", "engine" = "roxie"}
    # orchestrator_version = "2.9.0"
    # os_disk_size_gb      = 100
    # tags                 = {"mynodepooltag1" = "mytagvalue1", "mynodepooltag2" = "mytagvalue2"}

  }

  addpool1 = {
    vm_size                      = "Standard_D4_v4"
    auto_scaling_enabled         = true
    node_count                   = 2
    min_count                    = 1
    max_count                    = 2
    availability_zones           = []
    subnet                       = "public"
    priority                     = "Regular"
    spot_max_price               = -1
    max_surge                    = "1"
    os_type                      = "Linux"
    priority                     = "Regular"
    host_encryption_enabled      = false
    node_public_ip_enabled       = false
    only_critical_addons_enabled = false
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    # orchestrator_version         = "2.9.0"
    # os_disk_size_gb              = 100
    # max_pods                     = 20
    # node_labels                  = {"engine" = "roxie", "engine" = "roxie"}
    # eviction_policy              = "Spot"
    # node_taints                  = ["mytaint1", "mytaint2"]
    # proximity_placement_group_id = "my_proximity_placement_group_id"
    # spot_max_price               = 1
    # tags                         = {"mynodepooltag1" = "mytagvalue1", "mynodepooltag2" = "mytagvalue2"}
  }

  addpool2 = {
    vm_size                      = "Standard_D4_v4"
    auto_scaling_enabled         = true
    node_count                   = 2
    min_count                    = 1
    max_count                    = 2
    availability_zones           = []
    subnet                       = "public"
    priority                     = "Regular"
    spot_max_price               = -1
    max_surge                    = "1"
    os_type                      = "Linux"
    priority                     = "Regular"
    host_encryption_enabled      = false
    node_public_ip_enabled       = false
    only_critical_addons_enabled = false
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    # orchestrator_version         = "2.9.0"
    # os_disk_size_gb              = 100
    # max_pods                     = 20
    # node_labels                  = {"engine" = "roxie", "engine" = "roxie"}
    # eviction_policy              = "Spot"
    # node_taints                  = ["mytaint1", "mytaint2"]
    # proximity_placement_group_id = "my_proximity_placement_group_id"
    # spot_max_price               = 1
    # tags                         = {"mynodepooltag1" = "mytagvalue1", "mynodepooltag2" = "mytagvalue2"}
  }
}

# CHARTS 
# .......................

hpcc = {
  name                       = "myhpcck8s"
  image_version              = "9.10.0-rc3"
  expose_eclwatch            = true
  atomic                     = true
  recreate_pods              = false
  reuse_values               = false
  reset_values               = false
  force_update               = false
  namespace                  = "default"
  cleanup_on_fail            = false
  disable_openapi_validation = false
  max_history                = 0
  wait                       = true
  dependency_update          = true
  timeout                    = 900
  wait_for_jobs              = false
  lint                       = false
  remote_chart               = "https://hpcc-systems.github.io/helm-chart"
  # local_chart = "/Users/foo/work/demo/helm-chart/helm/hpcc" #Other examples: local_chart = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/hpcc-8.6.16-rc1.tgz"
  # values  = ["/Users/foo/mycustomvalues1.yaml", "/Users/foo/mycustomvalues2.yaml"]
  # image_root    = "west.lexisnexisrisk.com"
  # image_name    = "platform-core-ln"
}

storage = {
  default                    = false
  atomic                     = true
  recreate_pods              = false
  reuse_values               = false
  reset_values               = false
  force_update               = false
  namespace                  = "default"
  cleanup_on_fail            = false
  disable_openapi_validation = false
  max_history                = 0
  wait                       = true
  dependency_update          = true
  timeout                    = 600
  wait_for_jobs              = false
  lint                       = false
  remote_chart               = "https://hpcc-systems.github.io/helm-chart"
  # local_chart = "/Users/foo/work/demo/helm-chart/helm/examples/azure/hpcc-azurefile"
  # version                    = "0.1.0"
  # values = ["/Users/foo/mycustomvalues1.yaml", "/Users/foo/mycustomvalues2.yaml"]

  /*
  storage_accounts = {
    # do not change the key names 
    dali = {
      name = "dalikxgt"
      resource_group_name = "app-storageaccount-sandbox-eastus-79735"

      shares = {
        dali = {
          name = "dalishare"
          sub_path   = "dalistorage" //do not change this value
          category   = "dali" //do not change this value
          sku        = "Premium_LRS"
          quota      = 100
        }
      }
    }

    sasha = {
      name = "sashakxgt"
      resource_group_name = "app-storageaccount-sandbox-eastus-79735"

      shares = {
        sasha = {
          name = "sashashare"
          sub_path   = "sasha" //do not change this value
          category   = "sasha" //do not change this value
          sku        = "Standard_LRS"
          quota      = 100
        }
      }
    }

    common = {
      name = "commonkxgt"
      resource_group_name = "app-storageaccount-sandbox-eastus-79735"

      shares = {
        data = {
          name = "datashare"
          sub_path   = "hpcc-data" //do not change this value
          category   = "data" //do not change this value
          sku        = "Standard_LRS"
          quota      = 100
        }

        dll = {
          name = "dllshare"
          sub_path   = "queries" //do not change this value
          category   = "dll" //do not change this value
          sku        = "Standard_LRS"
          quota      = 100
        }

        mydropzone = {
          name = "mydropzoneshare"
          sub_path   = "dropzone" //do not change this value
          category   = "lz" //do not change this value
          sku        = "Standard_LRS"
          quota      = 100
        }
      }
    }
  }
  */
}

elastic4hpcclogs = {
  enable                     = false
  expose                     = true
  name                       = "myelastic4hpcclogs"
  atomic                     = true
  recreate_pods              = false
  reuse_values               = false
  reset_values               = false
  force_update               = false
  namespace                  = "default"
  cleanup_on_fail            = false
  disable_openapi_validation = false
  max_history                = 0
  wait                       = true
  dependency_update          = true
  timeout                    = 900
  wait_for_jobs              = false
  lint                       = false
  remote_chart               = "https://hpcc-systems.github.io/helm-chart"
  # local_chart = "/Users/foo/work/demo/helm-chart/helm/managed/logging/elastic"
  # version                    = "1.2.10"
  # values = ["/Users/foo/mycustomvalues1.yaml", "/Users/foo/mycustomvalues2.yaml"]
}

# expose_services - Expose ECLWatch and elastic4hpcclogs to the internet. This can be unsafe and may not be supported by your organization. 
# Setting this to true can cause eclwatch service to stick in a pending state. Only use this if you know what you are doing.
expose_services = true

# auto_connect - Automatically connect to the kubernetes cluster from the host machine.
auto_connect = true

# disable_helm - Disable Helm deployments by Terraform. This is reserved for experimentation with other deployment tools like Flux2.
# disable_helm = false 

# disable_naming_conventions - Disable naming conventions
# disable_naming_conventions = true 

# auto_launch_eclwatch - Automatically launch ECLWatch web interface.
auto_launch_eclwatch = true

/*
  # Provide an existing virtual network deployed outside of this project
  virtual_network = {
    private_subnet_id = "value"
    public_subnet_id  = "value"
    route_table_id    = "value"
    location          = "value"
  }
*/

/*
# Private Docker repository authentification
registry = {
  password = "my_api_key"
  server   = "westus.lexisnexisrisk.com"
  username = "foo@lexisnexisrisk.com"
}
*/

//Stops the AKS weekday nights at 6PM EST
aks_automation = {
  local_authentication_enabled  = false
  public_network_access_enabled = false
  automation_account_name       = "aks-automation-default-SYT0"
  resource_group_name           = "aa-us-hpccplatform-dev-eastus"
  create_new_account            = false
  create_new_role_assignment    = false

  schedule = [
    {
      schedule_name   = "aks_stop"
      description     = "Stops the AKS weekday nights"
      frequency       = "Week" //OneTime, Day, Hour, Week, or Month.
      interval        = "1"    //cannot be set when frequency is `OneTime`
      daylight_saving = true
      start_time      = "19:00" // At least 5 minutes in the future
      timezone        = "America/New_York"
      week_days       = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    },
    # {
    #   schedule_name   = "aks_start"
    #   description     = "Starts the AKS weekday nights at 6AM EST"
    #   frequency       = "Week" //OneTime, Day, Hour, Week, or Month.
    #   interval        = "1"    //cannot be set when frequency is `OneTime`
    #   daylight_saving = true
    #   start_time      = "12:20" // At least 5 minutes in the future
    #   week_days       = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    # }
  ]
}
