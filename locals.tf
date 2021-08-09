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

  repository = "https://hpcc-systems.github.io/helm-chart/"
  git_repo   = "https://github.com/hpcc-systems/helm-chart.git"

  hpcc_remote_chart    = "hpcc"
  storage_remote_chart = "hpcc-azurefile"
  elk_remote_chart     = "elastic4hpcclogs"

  local_chart         = var.use_local_charts && (var.hpcc_helm.local_chart == null || var.hpcc_helm.local_chart == "") ? "${path.root}/helm-chart" : var.hpcc_helm.local_chart
  hpcc_local_chart    = "${local.local_chart}/helm/hpcc"
  storage_local_chart = "${local.local_chart}/helm/examples/azure/hpcc-azurefile"
  elk_local_chart     = "${local.local_chart}/helm/managed/logging/elastic"

  custom_data = templatefile("${path.module}/local_exec.tpl", { version = var.hpcc_helm.chart_version, repository = local.git_repo })

  kube_admin_config = module.kubernetes.kube_config_raw

  apply = "apply -f ${path.root}/eclwatch-ingress.yaml"
}
