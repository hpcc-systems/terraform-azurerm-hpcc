admin = {
  name  = "hpccdemo"
  email = "hpccdemo@example.com"
}

metadata = {
  project             = "hpccdemo"
  product_name        = "storageaccount"
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

storage = {
  access_tier             = "Hot"
  account_kind            = "StorageV2"
  account_tier            = "Standard"
  replication_type        = "LRS"
  enable_large_file_share = true
  # auto_approval_subscription_ids = []

  quotas = {
    dali  = 1
    data  = 3
    dll   = 1
    lz    = 1
    sasha = 3
  }
}

# disable_naming_conventions = false # true will enforce all the arguments of the metadata block above

# Provide an existing virtual network deployed outside of this project
/*
virtual_network = {
  location       = "value"
  route_table_id = "value"
  private_subnet_id = "value"
  public_subnet_id  = "value"
}
*/
