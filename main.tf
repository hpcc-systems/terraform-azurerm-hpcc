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
  length  = 6
  special = true
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"

  count = var.disable_naming_conventions ? 0 : 1
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  count = var.disable_naming_conventions ? 0 : 1

  naming_rules = module.naming[0].yaml

  market              = var.metadata.market
  location            = var.resource_group.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = module.subscription.output.subscription_id
  project             = var.metadata.project
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  unique_name = var.resource_group.unique_name
  location    = var.resource_group.location
  names       = local.names
  tags        = local.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.9.0"

  naming_rules = var.disable_naming_conventions ? "" : module.naming[0].yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = local.names
  tags                = local.tags

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
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v4.2.1"

  count = var.disable_kubernetes ? 0 : 1

  cluster_name        = "${local.names.resource_group_type}-${local.names.product_name}-terraform-${local.names.location}-${var.admin.name}"
  location            = var.resource_group.location
  names               = local.names
  tags                = local.tags
  resource_group_name = module.resource_group.name

  identity_type = "UserAssigned" # Allowed values: UserAssigned or SystemAssigned

  rbac = {
    enabled        = false
    ad_integration = false
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
      vm_size                      = var.system_node_pool.vm_size
      node_count                   = var.system_node_pool.node_count
      only_critical_addons_enabled = true
      subnet                       = "private"
    }
    linuxweb = {
      vm_size             = var.additional_node_pool.vm_size
      enable_auto_scaling = var.additional_node_pool.enable_auto_scaling
      min_count           = var.additional_node_pool.min_count
      max_count           = var.additional_node_pool.max_count
      subnet              = "public"
    }
  }

  default_node_pool = "system"

}

resource "helm_release" "hpcc" {
  # count = var.disable_helm ? 0 : var.image_root != "" && var.image_root != null ? 1 : 0
  count = var.disable_helm ? 0 : 1

  name             = var.hpcc.name
  namespace        = var.hpcc.namespace
  chart            = local.hpcc_chart
  create_namespace = true
  values = concat(var.expose_services ? [file("${path.root}/values/esp.yaml")] : [], var.hpcc.values != null && var.hpcc.values != "" ?
  [for v in var.hpcc.values : file(v)] : [], [file("${path.root}/values/values-retained-azurefile.yaml")])

  dynamic "set" {
    for_each = var.image_root != "" && var.image_root != null && var.image_root != "hpccsystems" ? [1] : []
    content {
      name  = "global.image.root"
      value = var.image_root
    }
  }

  dynamic "set" {
    for_each = var.image_name != "" && var.image_name != null && var.image_name != "platform-core" ? [1] : []
    content {
      name  = "global.image.name"
      value = var.image_name
    }
  }

  dynamic "set" {
    for_each = var.image_version != "" && var.image_version != null ? [1] : []
    content {
      name  = "global.image.version"
      value = var.image_version
    }

  }

  dependency_update = true
  timeout           = 1000
  depends_on        = [helm_release.storage]
}

resource "helm_release" "storage" {
  count = var.disable_helm ? 0 : 1

  name             = "azstorage"
  namespace        = var.hpcc.namespace
  chart            = local.storage_chart
  values           = var.storage.values == null ? null : [for v in var.storage.values : file(v)]
  create_namespace = true

  timeout           = 600
  dependency_update = true
}

resource "helm_release" "elk" {
  count = var.disable_helm || !var.elk.enable ? 0 : 1

  name             = var.elk.name
  namespace        = var.hpcc.namespace
  chart            = local.elk_chart
  values           = concat(var.elk.values != null && var.elk.values != "" ? [for v in var.elk.values : file(v)] : [], var.expose_services ? [file("${path.root}/values/elk.yaml")] : [])
  create_namespace = true

  timeout           = 600
  dependency_update = true
  depends_on        = [helm_release.hpcc]
}

module "storage_account" {
  source = "github.com/Azure-Terraform/terraform-azurerm-storage-account.git?ref=v0.6.0"

  count = var.storage.disable_storage_account ? 0 : 1

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = local.names
  tags                = local.tags

  account_kind            = var.storage.account_kind
  replication_type        = var.storage.replication_type
  account_tier            = var.storage.account_tier
  access_tier             = var.storage.access_tier
  enable_large_file_share = var.storage.enable_large_file_share
  enable_static_website   = var.storage.enable_static_website

  access_list = {
    "my_ip" = chomp(data.http.my_ip.body)
  }

  service_endpoints = {
    "iaas-public" = module.virtual_network.subnet["iaas-public"].id
  }
}

resource "azurerm_network_security_rule" "ingress-internet" {
  count = var.expose_services ? 1 : 0

  name                        = "Allow_Internet_Ingress"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["8010", "5601"]
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = module.virtual_network.subnets["iaas-public"].resource_group_name
  network_security_group_name = module.virtual_network.subnets["iaas-public"].network_security_group_name
}


resource "null_resource" "az" {
  count = var.auto_connect ? 1 : 0

  provisioner "local-exec" {
    command     = local.az_command
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }

  depends_on = [module.kubernetes[0]]
}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes[0].name} --resource-group ${module.resource_group.name}"
}

output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}
