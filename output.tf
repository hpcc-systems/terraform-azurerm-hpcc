output "aks_login" {
  value = try("az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}", "")
}

output "advisor_recommendations" {
  value = try(data.azurerm_advisor_recommendations.advisor.recommendations, [])
}

output "storage_account_name" {
  value = module.storage_account.hpccsa.name
}

output "storage_account_resource_group_name" {
  value = module.storage_account.resource_group_name
}

output "storage_account_subscription_id" {
  value = module.storage_account.subscription_id
}
