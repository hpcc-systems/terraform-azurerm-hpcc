output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}

output "private_subnet_id" {
  value = module.virtual_network.aks.hpcc.subnets["private"].id
}

output "public_subnet_id" {
  value = module.virtual_network.aks.hpcc.subnets["public"].id
}

output "route_table_id" {
  value = module.virtual_network.aks.hpcc.route_table_id
}

resource "local_file" "output" {
  content  = local.vnet
  filename = "${path.module}/bin/outputs.json"
}


