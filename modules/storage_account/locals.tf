locals {
  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = var.metadata.business_unit
      environment       = var.metadata.environment
      location          = var.storage.location
      market            = var.metadata.market
      subscription_type = var.metadata.subscription_type
    },
    var.metadata.product_group != "" ? { product_group = var.metadata.product_group } : {},
    var.metadata.product_name != "" ? { product_name = var.metadata.product_name } : {},
    var.metadata.resource_group_type != "" ? { resource_group_type = var.metadata.resource_group_type } : {}
  ) : module.metadata.names

  tags     = var.disable_naming_conventions ? merge(var.tags, { "admin" = var.admin.name, "email" = var.admin.email, "workspace" = terraform.workspace }) : merge(module.metadata.tags, { "admin" = var.admin.name, "email" = var.admin.email, "workspace" = terraform.workspace }, try(var.tags))
  vnet     = can(var.virtual_network.private_subnet_id) && can(var.virtual_network.public_subnet_id) ? tomap({ private_subnet_id = var.virtual_network.private_subnet_id, public_subnet_id = var.virtual_network.public_subnet_id }) : tomap({ private_subnet_id = data.external.vnet[0].result.private_subnet_id, public_subnet_id = data.external.vnet[0].result.public_subnet_id })
  location = can(var.virtual_network.location) ? var.virtual_network.location : data.external.vnet[0].result.location
  storage_shares = { "dalishare" = var.storage.quotas.dali, "dllsshare" = var.storage.quotas.dll, "sashashare" = var.storage.quotas.sasha,
  "datashare" = var.storage.quotas.data, "lzshare" = var.storage.quotas.lz }
}
