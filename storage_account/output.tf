output "hpccsa" {
  value = azurerm_storage_account.storage_account
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}