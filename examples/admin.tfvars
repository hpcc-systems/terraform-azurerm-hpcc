admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

naming_conventions_enabled = true # true will enforce all metadata inputs below

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

hpcc_image = {
  version = "8.2.4-rc1"
  name    = "platform-core"
  root    = "hpccsystems"
}

hpcc_helm = {
  chart     = ""
  namespace = "default"
  name      = "myhpcck8s"
  values    = ["example.yaml"]
}

hpcc_elk = {
  enabled = true
  name    = "myhpccelk"
  values  = null
}

# Optional Attributes
# -------------------

# charts_version - The version of the charts if a custom image version is being used.
# Example: charts_version = "8.2.8"

# auto_connect - Automatically connect to the kubernetes cluster from the host machine
# Example: auto_connect = true 

# hpcc_storage - additional values.yaml for storage deployment
# Example: 
# hpcc_storage = {
#   values = ["example.yaml"]
# }
