output "resource_group_name" {
  value = module.resource_group.name
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "location" {
  value = module.resource_group.location
}

resource "local_file" "output" {
  content  = "{\"location\":\"${module.resource_group.location}\", \"resource_group_name\":\"${module.resource_group.name}\", \"name\":\"${module.storage_account.name}\"}"
  filename = "${path.module}/bin/outputs.json"
}
