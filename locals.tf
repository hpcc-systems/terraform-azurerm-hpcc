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

  tags = var.disable_naming_conventions ? merge(
    var.tags,
    {
      "owner" = var.admin.name,
      "owner_email" = var.admin.email
    }
    ) : merge(
    module.metadata.tags,
    {
      "owner" = var.admin.name,
      "owner_email" = var.admin.email
    },
    try(var.tags)
  )

  get_vnet_data = fileexists("${path.module}/modules/virtual_network/bin/vnet.json") ? jsondecode(file("${path.module}/modules/virtual_network/bin/vnet.json")) : null

  get_data_planes = fileexists("${path.module}/modules/storage_accounts/bin/data_planes.json") ? jsondecode(file("${path.module}/modules/storage_accounts/bin/data_planes.json")) : null

  virtual_network = can(var.virtual_network.private_subnet_id) && can(var.virtual_network.public_subnet_id) && can(var.virtual_network.route_table_id) ? var.virtual_network : local.get_vnet_data

  cluster_name = "${local.names.resource_group_type}-${local.names.product_name}-terraform-${local.names.location}-${var.admin.name}${random_integer.int.result}-${terraform.workspace}"

  data_planes = can(var.storage.storage_accounts) ? flatten([
    for k, v in var.storage.storage_accounts :
    [
      for x, y in v.shares : {
        "plane_name"       = "${x}"
        "sa_name"          = "${v.name}"
        "share_name"       = "${y.name}"
        "sub_path"         = "${y.sub_path}"
        "category"         = "${y.category}"
        "sku"              = "${y.sku}"
        "secret_name"      = "${v.name}-azure-secret"
        "secret_namespace" = "${terraform.workspace}"
        "quota"            = "${y.quota}Gi"
      }
    ]
  ]) : toset([for v in local.get_data_planes : merge(v, { "secret_name" = "${v.storage_account_name}-azure-secret", "secret_namespace" = "${terraform.workspace}" })])

  group_planes_by_sa = { for k, v in local.get_data_planes : v.storage_account_name => v... }

  storage_accounts = can(var.storage.storage_accounts) ? { for v in var.storage.storage_accounts : v.name => v.resource_group_name } : { for k, v in local.group_planes_by_sa : k => join(",", distinct([for x in v : x.resource_group_name])) }

  # sa_resource_group_names = can(var.storage.storage_accounts) ? { for k, v in var.storage.storage_accounts : k => v.resource_group_name } : { for k, v in local.get_data_planes : v.plane_name => v.resource_group_name }

  # sa_resource_group_name = values(local.sa_resource_group_names)[0]

  hpcc_azurefile = templatefile("${path.module}/values/hpcc-azurefile.tftpl", { planes = local.data_planes })

  hpcc_chart_major_minor_point_version = can(var.hpcc.chart_version) ? regex("[\\d+?.\\d+?.\\d+?]+", var.hpcc.chart_version) : "master"
  elastic4hpcclogs_hpcc_logaccess      = "https://raw.githubusercontent.com/hpcc-systems/helm-chart/${local.hpcc_chart_major_minor_point_version}/helm/managed/logging/elastic/elastic4hpcclogs-hpcc-logaccess.yaml"


  az_command    = try("az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name} --overwrite", "")
  web_urls      = { auto_launch_eclwatch = "http://$(kubectl get svc --field-selector metadata.name=eclwatch | awk 'NR==2 {print $4}'):8010" }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
