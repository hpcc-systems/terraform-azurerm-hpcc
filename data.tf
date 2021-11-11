data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["security", "cost"]
  filter_by_resource_groups = try([local.resource_group.name, var.storage.storage_account.resource_group_name], [module.resource_group.name])
}

data "http" "host_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

/*
data "azurerm_resource_group" "sa_rg" {
  name = var.storage.storage_account.resource_group_name
}*/

data "azurerm_storage_account" "hpccsa" {
  count = can(var.storage.storage_account.resource_group_name) ? 1 : 0

  name                = var.storage.storage_account.name
  resource_group_name = var.storage.storage_account.resource_group_name
}
