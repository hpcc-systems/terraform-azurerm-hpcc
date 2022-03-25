admin = {
  name  = "shuri"
  email = "shuri@blackgirlscode.com"
}

metadata = {
  project             = "hpccdemo"
  product_name        = "vnet"
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
  location    = "eastus"
}

# Optional Attributes
# -------------------

# Disable naming conventions
# disable_naming_conventions = true 
