  admin = {
  name  = "shuri"
  email = "shuri@blackgirlscode.com"
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
  access_tier                       = "Hot"
  account_kind                      = "StorageV2"
  account_tier                      = "Standard"
  replication_type                  = "LRS"
  enable_large_file_share           = true
  enable_https_traffic_only         = true
  traffic_bypass                    = ["Logging", "Metrics", "AzureServices"]
  min_tls_version                   = "TLS1_2"
  nfsv3_enable                      = false
  infrastructure_encryption_enabled = false
  shared_access_key_enabled         = true
  enable_hns                        = false
  allow_blob_public_access          = false
  allow_host_ip                     = true
  # auto_approval_subscription_ids = []

  # Quotas in Gigabytes
  quotas = {
    dali  = 1
    data  = 3
    dll   = 1
    lz    = 1
    sasha = 3
  }
}

# Optional Attributes
# -------------------

# Disable naming conventions
# disable_naming_conventions = true 

/*
  # Grant access to an existing virtual network that was deployed outside of this project
  virtual_network = {
    private_subnet_id = "value"
    public_subnet_id  = "value"
    route_table_id    = "value"
    location          = "value"
  }
*/
