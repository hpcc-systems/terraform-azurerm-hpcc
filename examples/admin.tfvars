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
    max_count                    = 2
    availability_zones           = []
    subnet                       = "private"
  }

  addpool1 = {
    vm_size             = "Standard_D4_v4"
    enable_auto_scaling = true
    node_count          = 2
    min_count           = 1
    max_count           = 2
    availability_zones  = []
    subnet              = "public"
    priority            = "Regular"
    spot_max_price      = -1
  }

  addpool2 = {
    vm_size             = "Standard_D4_v4"
    enable_auto_scaling = true
    node_count          = 2
    min_count           = 1
    max_count           = 2
    availability_zones  = []
    subnet              = "public"
    priority            = "Regular"
    spot_max_price      = -1
  }
}

# CHARTS 
# .......................

hpcc = {
  version = "8.4.14-rc1"
  name    = "myhpcck8s"
  atomic  = true
}

elk = {
  enable = false
  name   = "myhpccelk"
  # chart  = ""
  # values = ""
}

storage = {
  default = false
  # chart  = ""
  # values = []
  /*
  storage_account = {
    location            = "eastus"
    name                = "demohpccsa3"
    resource_group_name = "app-storageaccount-sandbox-eastus-48936"
    # subscription_id     = ""
  }
  */
}

# Optional Attributes
# -------------------

# expose_services - Expose ECLWatch and ELK to the internet. This can be unsafe and may not be supported by your organization. 
# Setting this to true can cause eclwatch service to stick in a pending state. Only use this if you know what you are doing.
expose_services = true

# image_root - Root of the image other than hpccsystems
#  image_root = "foo"

# image_name - Name of the image other than platform-core
# image_name = "bar"

# image_version - Version of the image
# image_version = "bar"

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
    private_subnet_id = ""
    public_subnet_id  = ""
    route_table_id    = ""
    location          = ""
  }
*/
