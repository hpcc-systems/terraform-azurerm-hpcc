data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["Security", "Cost"]
  filter_by_resource_groups = try([azurerm_resource_group.default["aks"].name, var.storage.storage_account.resource_group_name], [azurerm_resource_group.default["aks"].name])
}

data "azurerm_subscription" "current" {
}

data "azurerm_storage_account" "hpccsa" {
  for_each = local.storage_accounts

  name                = each.key
  resource_group_name = each.value
}

data "http" "elastic4hpcclogs_hpcc_logaccess" {

  url = local.elastic4hpcclogs_hpcc_logaccess
}

data "azurerm_automation_account" "default" {
  count = var.aks_automation.create_new_account ? 0 : 1

  name                = var.aks_automation.automation_account_name
  resource_group_name = var.aks_automation.resource_group_name
}
