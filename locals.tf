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
  tags            = var.disable_naming_conventions ? merge(var.tags, { "admin" = var.admin.name, "email" = var.admin.email }) : merge(module.metadata.tags, { "admin" = var.admin.name, "email" = var.admin.email }, try(var.tags))
  virtual_network = var.virtual_network != null ? var.virtual_network : data.external.vnet[0].result
  cluster_name    = "${local.names.resource_group_type}-${local.names.product_name}-terraform-${local.names.location}-${var.admin.name}-${terraform.workspace}"

  hpcc_repository = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/hpcc-${var.hpcc.version}.tgz"
  hpcc_chart      = can(var.hpcc.chart) ? var.hpcc.chart : local.hpcc_repository
  hpcc_name       = can(var.hpcc.name) ? var.hpcc.name : "myhpcck8s"


  storage_version    = can(var.storage.version) ? var.storage.version : "0.1.0"
  storage_repository = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/hpcc-azurefile-${local.storage_version}.tgz"
  storage_chart      = can(var.storage.chart) ? var.storage.chart : local.storage_repository
  storage_account    = try(try(var.storage.storage_account, data.external.sa[0].result), "")

  elk_version    = can(var.elk.version) ? var.elk.version : "1.2.1"
  elk_repository = "https://github.com/hpcc-systems/helm-chart/raw/master/docs/elastic4hpcclogs-${local.elk_version}.tgz"
  elk_chart      = can(var.elk.chart) ? var.elk.chart : local.elk_repository
  elk_name       = can(var.elk.name) ? var.elk.name : "myhpccelk"

  az_command    = try("az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name} --overwrite", "")
  web_urls      = { auto_launch_eclwatch = "http://$(kubectl get svc --field-selector metadata.name=eclwatch | awk 'NR==2 {print $4}'):8010" }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
