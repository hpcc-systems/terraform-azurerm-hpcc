data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["security", "cost"]
  filter_by_resource_groups = [module.resource_group.name]
}

data "azurerm_subscription" "current" {
}
