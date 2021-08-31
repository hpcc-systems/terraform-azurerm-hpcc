resource "random_string" "random" {
  length  = 43
  upper   = false
  number  = false
  special = false
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
  location            = var.storage.location
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

  unique_name = var.unique_name
  location    = var.storage.location
  names       = local.names
  tags        = var.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.9.0"

  naming_rules = var.naming_rules

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = local.names
  tags                = var.tags

  address_space = ["10.1.0.0/22"]

  subnets = {
    iaas-private = {
      cidrs                   = ["10.1.0.0/24"]
      route_table_association = "default"
      configure_nsg_rules     = false
    }
    iaas-public = {
      cidrs                                          = ["10.1.1.0/24"]
      route_table_association                        = "default"
      configure_nsg_rules                            = false
      enforce_private_link_endpoint_network_policies = true
      enforce_private_link_service_network_policies  = true
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

resource "azurerm_public_ip" "public_ip" {
  name                = "private_link_public_ip"
  sku                 = "Standard"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "private_link_lb" {
  name                = "private_link_lb"
  sku                 = "Standard"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.public_ip.name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_private_link_service" "private_link_svc" {
  name                = "sa_privatelink"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  auto_approval_subscription_ids              = [can(var.existing_storage.subscription_id) ? var.existing_storage.subscription_id : data.azurerm_subscription.current.subscription_id]
  visibility_subscription_ids                 = [can(var.existing_storage.subscription_id) ? var.existing_storage.subscription_id : data.azurerm_subscription.current.subscription_id]
  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.private_link_lb.frontend_ip_configuration.0.id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address         = "10.1.1.17"
    private_ip_address_version = "IPv4"
    subnet_id                  = module.virtual_network.subnets["iaas-public"].id
    primary                    = true
  }

  nat_ip_configuration {
    name                       = "secondary"
    private_ip_address         = "10.1.1.18"
    private_ip_address_version = "IPv4"
    subnet_id                  = module.virtual_network.subnets["iaas-public"].id
    primary                    = false
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                = "hpccsa"
  resource_group_name = module.resource_group.name

  location                 = module.resource_group.location
  account_tier             = var.storage.account_tier
  account_replication_type = var.storage.account_replication_type
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

resource "azurerm_storage_share" "storage_shares" {
  for_each = can(var.existing_storage.name) ? {} : local.storage_shares

  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = each.value

  acl {
    id = random_string.random.result

    access_policy {
      permissions = "rwdl"
    }
  }
}
