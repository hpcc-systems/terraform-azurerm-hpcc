provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes.kube_config.host
  client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.kube_config.host
    client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
    client_key             = base64decode(module.kubernetes.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
  }
}

locals {
  admin        = "hpccdemo"
  project_name = "test"
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

resource "random_password" "admin" {
  length  = 14
  special = true
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  naming_rules = module.naming.yaml

  market              = "us"
  location            = "eastus2"
  sre_team            = "hpcc_platform"
  environment         = "dev"
  product_name        = "contosoweb"
  business_unit       = "commercial"
  product_group       = "contoso"
  subscription_type   = "nonprod"
  resource_group_type = "app"
  subscription_id     = module.subscription.output.subscription_id
  project             = local.project_name
}

module "resource_group" {
  source = "../terraform-azurerm-resource-group"

  user        = local.admin
  unique_name = true
  location    = module.metadata.location
  names       = module.metadata.names
  tags        = merge(module.metadata.tags, { "admin" : local.admin })
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.9.0"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.0.0/22"]

  subnets = {
    iaas-private = {
      cidrs                   = ["10.1.0.0/24"]
      route_table_association = "default"
      configure_nsg_rules     = false
    }
    iaas-public = {
      cidrs                   = ["10.1.1.0/24"]
      route_table_association = "default"
      configure_nsg_rules     = false
    }
  }

  route_tables = {
    default = {
      disable_bgp_route_propagation = true
      routes = {
        internet = {
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
        local-vnet = {
          address_prefix = "10.1.0.0/22"
          next_hop_type  = "vnetlocal"
        }
      }
    }
  }
}

module "kubernetes" {
  # source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v4.2.0"
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v4.2.1"

  location            = module.metadata.location
  names               = module.metadata.names
  tags                = module.metadata.tags
  resource_group_name = module.resource_group.name

  identity_type = "UserAssigned" # Allowed values: UserAssigned or SystemAssigned

  rbac = {
    enabled        = false
    ad_integration = false
  }

  windows_profile = {
    admin_username = local.admin
    admin_password = random_password.admin.result
  }

  network_plugin         = "azure"
  configure_network_role = true

  virtual_network = {
    subnets = {
      private = {
        id = module.virtual_network.subnets["iaas-private"].id
      }
      public = {
        id = module.virtual_network.subnets["iaas-public"].id
      }
    }
    route_table_id = module.virtual_network.route_tables["default"].id
  }

  node_pools = {
    system = {
      vm_size                      = "Standard_B2s"
      node_count                   = 2
      only_critical_addons_enabled = true
      subnet                       = "private"
    }
    linuxweb = {
      vm_size             = "Standard_B2ms"
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 3
      subnet              = "public"
    }
    # winweb = {
    #   vm_size             = "Standard_D4a_v4"
    #   os_type             = "Windows"
    #   enable_auto_scaling = true
    #   min_count           = 1
    #   max_count           = 3
    #   subnet              = "public"
    # }
  }

  default_node_pool = "system"

}


module "hpcc_helm" {
  source = "github.com/gfortil/terraform-azurerm-hpcc-helm.git?ref=v1.0.0"

  helm_provider = {
    host                   = module.kubernetes.kube_config.host
    client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
    client_key             = base64decode(module.kubernetes.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
  }

  chart_version = "8.2.4"

  aks_helm = {
    local_chart_enabled = true

    name          = "myhpcck8s"
    image_version = "8.2.4-rc1"
    image_root    = "hpccsystems"
    image_name    = "platform-core"
    namespace     = "default"
    local_path    = "/Users/godji/work/HPCC-Platform/helm/hpcc"
    chart         = "hpcc"
    repository    = "https://hpcc-systems.github.io/helm-chart/"
    values = [
      "/Users/godji/work/HPCC-Platform/helm/examples/azure/values-retained-azurefile.yaml",
      "/Users/godji/work/cloud/esp.yaml",
    ] #list of desired state files
  }

  storage_helm = {
    name       = "azstorage"
    local_path = "/Users/godji/work/HPCC-Platform/helm/examples/azure/hpcc-azurefile"
    chart      = "hpcc-azurefile"
    values     = "/Users/godji/work/HPCC-Platform/helm/examples/azure/hpcc-azurefile/values.yaml"
  }

  elk_helm = {
    name       = "myhpccelk"
    chart      = "elastic4hpcclogs"
    repository = "https://hpcc-systems.github.io/helm-chart/"
    local_path = "/Users/godji/work/HPCC-Platform/helm/managed/logging/elastic"
  }
}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}"
}
