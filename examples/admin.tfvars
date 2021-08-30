admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

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

node_pools = {
  system = {
    vm_size             = "Standard_B2s"
    node_count          = 1
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
  }

  addpool1 = {
    vm_size             = "Standard_B2ms"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
  }

  addpool2 = {
    vm_size             = "Standard_B2ms"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }
}

hpcc = {
  version   = "8.2.12-rc1"
  namespace = "default"
  name      = "myhpcck8s"
  chart     = null
  values    = []
}

elk = {
  enable = true
  name   = "myhpccelk"
  chart  = null
  values = null
}

storage = {
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  chart                    = null
  values                   = []

  quotas = {
    dali  = 3
    data  = 2
    dll   = 2
    lz    = 2
    sasha = 5
  }
}

# Optional Attributes
# -------------------
# expose_services - Expose ECLWatch and ELK to the internet. This can be unsafe and may not be supported by your organization. 
# Setting this to true can cause eclwatch service to stick in a pending state. Only use this if you know what you are doing.
# Example: expose_services = true

# image_root - Root of the image other than hpccsystems
# Example: image_root = "foo"

# image_name - Name of the image other than platform-core
# Example: image_name = "bar"

# image_version - Version of the image
# Example: image_version = "bar"

# auto_connect - Automatically connect to the kubernetes cluster from the host machine.
# Example: auto_connect = true 

# disable_helm - Disable Helm deployments by Terraform. This is reserved for experimentation with other deployment tools like Flux2.
# Example: disable_helm = false 

# delete_aks - Gracefully shut the Kubernetes cluster down and leaves the storage. terraform apply -var-file=admin.tfvars is needed afterwards.
# Example: delete_aks = true 

# disable_naming_conventions - Disable naming conventions
# Example: disable_naming_conventions = true 

# existing_storage - Connect to an existing storage account.
# Example:
# existing_storage = {
#   name                = "carinaindia"
#   resource_group_name = "carina-india-sa"
#   subscription_id     = ""
# }
