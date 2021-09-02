data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["security", "cost"]
  filter_by_resource_groups = [module.resource_group.name, var.storage.resource_group_name]
}

data "http" "host_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

data "azurerm_storage_account" "hpccsa" {

  name                = var.storage.name
  resource_group_name = var.storage.resource_group_name
}
