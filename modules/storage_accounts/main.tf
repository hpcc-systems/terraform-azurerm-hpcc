resource "random_string" "random" {
  length  = 4
  special = false
}

resource "random_uuid" "random" {

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

  market              = var.metadata.market
  location            = local.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = data.azurerm_subscription.current.id
  project             = var.metadata.project
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  unique_name = var.resource_group.unique_name
  location    = local.location
  names       = local.names
  tags        = local.tags
}

module "storage_accounts" {
  source   = "github.com/Azure-Terraform/terraform-azurerm-storage-account.git?ref=v0.12.1"
  for_each = var.storage_accounts

  name                = substr(lower("${each.key}${random_string.random.result}"), 0, 24)
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags

  account_kind              = each.value.account_kind
  replication_type          = each.value.replication_type
  account_tier              = each.value.account_tier
  access_tier               = each.value.access_tier
  enable_large_file_share   = each.value.enable_large_file_share
  shared_access_key_enabled = each.value.shared_access_key_enabled
  access_list = {
    "my_ip" = data.http.host_ip.body
  }

  service_endpoints = local.vnet
}

resource "azurerm_storage_share" "storage_shares" {
  for_each = { for share in local.shares : "${share.name}" => share }

  name                 = lower("${each.key}share")
  storage_account_name = each.value.sa_name
  quota                = each.value.quota
  # access_tier          = each.value.access_tier
  enabled_protocol = each.value.enabled_protocol
  acl {
    id = random_uuid.random.result

    access_policy {
      permissions = each.value.permissions
      start       = can(each.value.start) ? each.value.start : null
      expiry      = can(each.value.expiry) ? each.value.expiry : null
    }
  }
}
