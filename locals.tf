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
  ) : module.metadata[0].names

  tags = var.disable_naming_conventions ? merge(var.tags, { "admin" = var.admin.name, "email" = var.admin.email }) : merge(module.metadata[0].tags, { "admin" = var.admin.name, "email" = var.admin.email }, try(var.tags))

  hpcc_repository    = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/hpcc-${var.hpcc.version}.tgz"
  storage_repository = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/hpcc-azurefile-0.1.0.tgz"
  elk_repository     = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/elastic4hpcclogs-1.0.0.tgz"

  hpcc_chart    = var.hpcc.chart != "" && var.hpcc.chart != null ? var.hpcc.chart : local.hpcc_repository
  storage_chart = var.storage.chart != "" && var.storage.chart != null ? var.storage.chart : local.storage_repository
  elk_chart     = var.elk.chart != "" && var.elk.chart != null ? var.elk.chart : local.elk_repository

  az_command = "az aks get-credentials --name ${module.kubernetes[0].name} --resource-group ${module.resource_group.name} --overwrite"

  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
