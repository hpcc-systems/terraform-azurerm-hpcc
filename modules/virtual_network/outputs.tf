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
  content  = "{ \"location\":\"${module.resource_group.location}\", \"private_subnet_id\" : \"${local.private_subnet_id}\", \"public_subnet_id\" : \"${local.public_subnet_id}\", \"route_table_id\" : \"${local.route_table_id}\" }"
  filename = "${path.module}/bin/outputs.json"
}


