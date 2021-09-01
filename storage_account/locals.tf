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

  storage_shares = { "dalishare" = var.storage.quotas.dali, "dllsshare" = var.storage.quotas.dll, "sashashare" = var.storage.quotas.sasha,
  "datashare" = var.storage.quotas.data, "lzshare" = var.storage.quotas.lz }
}
