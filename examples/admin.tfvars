admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

enable_naming_conventions = true # true will enforce all metadata inputs below

metadata = {
  project             = "hpccdemo"
  product_name        = "contosoweb"
  business_unit       = "commercial"
  environment         = "dev"
  market              = "us"
  product_group       = "contoso"
  resource_group_type = "app"
  sre_team            = "hpccplatform"
  subscription_type   = "dev"
}

tags = { "justification" = "testing" }

resource_group = {
  unique_name = true
  location    = "eastus2"
}

system_node_pool = {
  vm_size    = "Standard_B2s"
  node_count = 2
}

additional_node_pool = {
  vm_size             = "Standard_B2ms"
  enable_auto_scaling = true
  min_count           = 1
  max_count           = 3
}

hpcc = {
  version   = "8.2.12-rc1"
  chart     = ""
  namespace = "default"
  name      = "myhpcck8s"
  chart     = null
  values    = ["example.yaml"]
}

elk = {
  enable = true
  name   = "myhpccelk"
  chart  = null
  values = null
}

# Optional Attributes
# -------------------
# image_root - Root of the image other than hpccsystems
# Example: image_root = "foo"

# image_name - Name of the image other than platform-core
# Example: image_name = "bar"

# auto_connect - Automatically connect to the kubernetes cluster from the host machine.
# Example: auto_connect = true 

# disable_helm - Disable Helm deployments by Terraform.
# Example: disable_helm = false 

# disable_kubernetes - Gracefully shut the Kubernetes cluster down. terraform apply -var-file=admin.tfvars is needed afterwards.
# Example: disable_kubernetes = true 

# enable_nginx - Enable NGINX for ECLWatch
# Example: enable_nginx = true  

# storage - Additional values.yaml for storage deployment.
# Example: 
# storage = {
#   disable_storage_account = false
#   access_tier             = "Hot"
#   account_kind            = "StorageV2"
#   account_tier            = "Premium"
#   chart                   = null
#   enable_large_file_share = "false"
#   replication_type        = "LRS"
#   values                  = []
# }
