locals {
  names = var.naming_conventions_enabled ? module.metadata[0].names : merge(
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
  )

  tags = var.naming_conventions_enabled ? merge(module.metadata[0].tags, { "admin" = var.admin.name, "email" = var.admin.email }, var.tags) : merge(var.tags, { "admin" = var.admin.name, "email" = var.admin.email })

  git_repo      = "https://github.com/hpcc-systems/helm-chart.git"
  chart_prefix  = var.hpcc_helm.chart == null || var.hpcc_helm.chart == "" ? "${path.root}/helm-chart" : var.hpcc_helm.chart
  hpcc_chart    = "${local.chart_prefix}/helm/hpcc"
  storage_chart = "${local.chart_prefix}/helm/examples/azure/hpcc-azurefile"
  elk_chart     = "${local.chart_prefix}/helm/managed/logging/elastic"
  version       = var.charts_version != null && var.charts_version != "" ? var.charts_version : regex("[(\\d)*].[(\\d)*].[(\\d)*]", var.hpcc_image.version)

  custom_data = templatefile(!local.is_windows_os ? "${path.module}/bash.tpl" : "${path.module}/batch.tpl", { version = local.version, repository = local.git_repo })

  kubectl_command = "kubectl apply -f ${path.root}/eclwatch-ingress.yaml"
  az_command      = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name} --overwrite"

  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
