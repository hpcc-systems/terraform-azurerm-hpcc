locals {

  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = var.metadata.business_unit
      environment       = var.metadata.environment
      location          = var.resource_group.location
      market            = var.metadata.market
      subscription_type = var.metadata.subscription_type
    },
    var.metadata.product_group != "" ? { product_group = var.metadata.product_group } : {},
    var.metadata.product_name != "" ? { product_name = var.metadata.product_name } : {},
    var.metadata.resource_group_type != "" ? { resource_group_type = var.metadata.resource_group_type } : {}
  ) : module.metadata.names

  tags = var.disable_naming_conventions ? merge(var.tags, { "admin" = var.admin.name, "email" = var.admin.email }) : merge(module.metadata.tags, { "admin" = var.admin.name, "email" = var.admin.email }, try(var.tags))

  private_subnet_id = module.virtual_network.aks.hpcc.subnets["private"].id
  public_subnet_id  = module.virtual_network.aks.hpcc.subnets["public"].id
  route_table_id    = module.virtual_network.aks.hpcc.route_table_id

  vnet = jsonencode({
    "private_subnet_id" : "${local.private_subnet_id}",
    "public_subnet_id" : "${local.public_subnet_id}",
    "location" : "${module.resource_group.location}",
    "route_table_id" : "${local.route_table_id}"
  })
}
