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
  virtual_network = can(var.virtual_network.private_subnet_id) && can(var.virtual_network.public_subnet_id) && can(var.virtual_network.route_table_id) ? var.virtual_network : data.external.vnet[0].result
  cluster_name    = "${local.names.resource_group_type}-${local.names.product_name}-terraform-${local.names.location}-${var.admin.name}${random_integer.int.result}-${terraform.workspace}"
  storage_account = can(var.storage.storage_account.resource_group_name) && can(var.storage.storage_account.name) && can(var.storage.storage_account.location) ? var.storage.storage_account : data.external.sa[0].result

  hpcc_chart_major_minor_point_version = can(var.hpcc.chart_version) ? regex("[\\d+?.\\d+?.\\d+?]+", var.hpcc.chart_version) : "master"
  elastic4hpcclogs_hpcc_logaccess      = "https://raw.githubusercontent.com/hpcc-systems/helm-chart/${local.hpcc_chart_major_minor_point_version}/helm/managed/logging/elastic/elastic4hpcclogs-hpcc-logaccess.yaml"

  az_command    = try("az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name} --overwrite", "")
  web_urls      = { auto_launch_eclwatch = "http://$(kubectl get svc --field-selector metadata.name=eclwatch | awk 'NR==2 {print $4}'):8010" }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
