data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["Security", "Cost"]
  filter_by_resource_groups = try([module.resource_group.name, var.storage.storage_account.resource_group_name], [module.resource_group.name])
}

data "http" "host_ip" {
  url = "http://ipv4.icanhazip.com"
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
