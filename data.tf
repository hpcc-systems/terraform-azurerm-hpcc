data "azurerm_advisor_recommendations" "advisor" {
  filter_by_category        = ["security", "cost"]
  filter_by_resource_groups = [module.resource_group[0].name, module.storage_account.resource_group_name]
}

data "http" "host_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

data "azurerm_storage_account" "existing_sa" {
  count               = can(var.existing_storage.name) && can(var.existing_storage.resource_group_name) ? 1 : 0
  name                = var.existing_storage.name
  resource_group_name = var.existing_storage.resource_group_name
}
