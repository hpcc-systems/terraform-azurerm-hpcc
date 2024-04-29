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

storage_accounts = {
  # do not change the names of the keys
  dali = {
    access_tier               = "Hot"
    account_kind              = "FileStorage"
    account_tier              = "Premium"
    replication_type          = "LRS"
    enable_large_file_share   = true
    shared_access_key_enabled = true

    shares = {
      dali = {
        quota            = 100
        permissions      = "rwdl"
        access_tier      = "Premium"     # Hot, Cool, TransactionOptimized, Premium
        enabled_protocol = "SMB"         # SMB, NFS
        sub_path         = "dalistorage" # do not change this line
        category         = "dali"        # do not change this line
        # start = "2022-06-13T22:31:31.612Z"
        # expiry = "2022-06-14T22:31:31.612Z"
      }
    }
  }

  sasha = {
    access_tier               = "Hot"
    account_kind              = "FileStorage"
    account_tier              = "Premium"
    replication_type          = "LRS"
    enable_large_file_share   = true
    shared_access_key_enabled = true

    shares = {
      sasha = {
        quota            = 100
        permissions      = "rwdl"
        access_tier      = "Premium" # Hot, Cool, TransactionOptimized, Premium
        enabled_protocol = "SMB"     # SMB, NFS
        sub_path         = "sasha"   # do not change this line
        category         = "sasha"   # do not change this line
        # start = "2022-06-13T22:31:31.612Z"
        # expiry = "2022-06-14T22:31:31.612Z"
      }
    }
  }

  common = {
    access_tier               = "Hot"
    account_kind              = "StorageV2"
    account_tier              = "Standard"
    replication_type          = "LRS"
    shared_access_key_enabled = true
    enable_large_file_share   = true

    shares = {
      data = {
        quota            = 100
        permissions      = "rwdl"
        access_tier      = "Premium"   # Hot, Cool, TransactionOptimized, Premium
        enabled_protocol = "SMB"       # SMB, NFS
        sub_path         = "hpcc-data" # do not change this line
        category         = "data"      # do not change this line
        # start = "2022-06-13T22:31:31.612Z"
        # expiry = "2022-06-14T22:31:31.612Z"
      }

      dll = {
        quota            = 100
        permissions      = "rwdl"
        access_tier      = "Premium" # Hot, Cool, TransactionOptimized, Premium
        enabled_protocol = "SMB"     # SMB, NFS
        sub_path         = "queries" # do not change this line
        category         = "dll"     # do not change this line
        # start = "2022-06-13T22:31:31.612Z"
        # expiry = "2022-06-14T22:31:31.612Z"
      }

      mydropzone = {
        quota            = 100
        permissions      = "rwdl"
        access_tier      = "Premium"  # Hot, Cool, TransactionOptimized, Premium
        enabled_protocol = "SMB"      # SMB, NFS
        sub_path         = "dropzone" # do not change this line
        category         = "lz"       # do not change this line
        # start = "2022-06-13T22:31:31.612Z"
        # expiry = "2022-06-14T22:31:31.612Z"
      }
    }
  }
}

# authorized_ip_ranges = {
#   "ip_1" = ""
# }

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
