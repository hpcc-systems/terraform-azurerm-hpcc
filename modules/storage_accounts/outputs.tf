output "resource_group_name" {
  value = module.resource_group.name
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "storage_accounts" {
  value = [for v in module.storage_accounts : v.name]
}

output "shares" {
  value = jsondecode(local.output)
}

output "vnet" {
  value = local.vnet
}

output "location" {
  value = module.resource_group.location
}

resource "local_file" "output" {
  content  = local.output
  filename = "${path.module}/bin/data_planes.json"
}
