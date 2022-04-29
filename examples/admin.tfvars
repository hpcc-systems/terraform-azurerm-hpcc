admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

metadata = {
  project             = "hpccdemo"
  product_name        = "aks"
  business_unit       = "commercial"
  environment         = "sandbox"
  market              = "us"
  product_group       = "contoso"
  resource_group_type = "app"
  sre_team            = "hpccplatform"
  subscription_type   = "dev"
}

tags = { "justification" = "testing" }

resource_group = {
  unique_name = true
}

node_pools = {
  system = {
    vm_size                      = "Standard_D4_v4"
    node_count                   = 1
    enable_auto_scaling          = true
    only_critical_addons_enabled = true
    min_count                    = 1
    max_count                    = 1
    availability_zones           = []
    subnet                       = "public"
    enable_host_encryption       = false
    enable_node_public_ip        = false
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
    enable_auto_scaling          = true
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
    enable_host_encryption       = false
    enable_node_public_ip        = false
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
    enable_auto_scaling          = true
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
    enable_host_encryption       = false
    enable_node_public_ip        = false
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
  # version                    = "8.6.14-rc2"
  # values  = ["/Users/foo/mycustomvalues1.yaml", "/Users/foo/mycustomvalues2.yaml"]
  # image_root    = "west.lexisnexisrisk.com"
  # image_name    = "platform-core-ln"
  # image_version = "8.6.18-rc1"
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
  storage_account = {
    location            = "eastus"
    name                = "foohpccsa3"
    resource_group_name = "app-storageaccount-sandbox-eastus-48936"
    # subscription_id   = "value"
  }
  */
}

elastic4hpcclogs = {
  enable                     = true
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
  timeout                    = 300
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
