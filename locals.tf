locals {
  tags = merge(
    var.tags,
    {
      "owner"       = var.admin.name,
      "owner_email" = var.admin.email
  })

  get_vnet_data = fileexists("${path.module}/modules/virtual_network/bin/vnet.json") ? jsondecode(file("${path.module}/modules/virtual_network/bin/vnet.json")) : null

  get_data_planes = fileexists("${path.module}/modules/storage_accounts/bin/data_planes.json") ? jsondecode(file("${path.module}/modules/storage_accounts/bin/data_planes.json")) : null

  virtual_network = var.virtual_network != null ? var.virtual_network : local.get_vnet_data

  cluster_name = "aks-terraform-${local.virtual_network.location}-${var.admin.name}${random_integer.int.result}-${terraform.workspace}"

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

  hpcc_azurefile = templatefile("${path.module}/values/hpcc-azurefile.tftpl", { planes = local.data_planes })

  hpcc_chart_major_minor_point_version = var.hpcc.image_version != null ? regex("[\\d+?.\\d+?.\\d+?]+", var.hpcc.image_version) : "master"
  elastic4hpcclogs_hpcc_logaccess      = "https://raw.githubusercontent.com/hpcc-systems/helm-chart/${local.hpcc_chart_major_minor_point_version}/helm/managed/logging/elastic/elastic4hpcclogs-hpcc-logaccess.yaml"


  az_command    = try("az aks get-credentials --name ${azurerm_kubernetes_cluster.aks.name} --resource-group ${azurerm_resource_group.default["aks"].name} --overwrite", "")
  web_urls      = { auto_launch_eclwatch = "http://$(kubectl get svc --field-selector metadata.name=eclwatch | awk 'NR==2 {print $4}'):8010" }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true

  runbook      = { for rb in var.runbook : "${rb.runbook_name}" => rb }
  current_time = timestamp()
  current_day  = formatdate("EEEE", local.current_time)
  current_hour = tonumber(formatdate("HH", local.current_time))
  today        = formatdate("YYYY-MM-DD", local.current_time)
  tomorrow     = formatdate("YYYY-MM-DD", timeadd(local.current_time, "24h"))
  # today        = formatdate("YYYY-MM-DD", timeadd(local.current_time, "1h"))

  utc_offset = var.aks_automation.schedule[0].daylight_saving ? 4 : 5

  script   = { for item in fileset("${path.root}/scripts", "*") : (item) => file("${path.root}/scripts/${item}") }
  schedule = { for s in var.aks_automation.schedule : "${s.schedule_name}" => s }

  user_assigned_identity_name = (var.user_assigned_identity_name == null ? "aks-${local.cluster_name}-control-plane" : var.user_assigned_identity_name)

  aks_identity_id = (var.identity_type == "SystemAssigned" ? azurerm_kubernetes_cluster.aks.identity.0.principal_id :
  (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks.0.principal_id : var.user_assigned_identity.principal_id))

  node_resource_group = (var.node_resource_group != null ? var.node_resource_group : "MC_${local.cluster_name}")

  dns_prefix = var.dns_prefix

  node_pools = zipmap(keys(var.node_pools), [for node_pool in values(var.node_pools) : merge(var.node_pool_defaults, node_pool)])

  windows_nodes = (length([for v in local.node_pools : v if lower(v.os_type) == "windows"]) > 0 ? true : false)

  additional_node_pools = { for k, v in local.node_pools : k => v if k != var.default_node_pool }

  kube_config = (var.rbac.enabled ? azurerm_kubernetes_cluster.aks.kube_admin_config.0 : azurerm_kubernetes_cluster.aks.kube_config.0)

  vnet_ids = {
    subnets = {
      private = {
        id = local.virtual_network.private_subnet_id
      }
      public = {
        id = local.virtual_network.public_subnet_id
      }
    }
    route_table_id = local.virtual_network.route_table_id
  }

  automation_account_name = var.aks_automation.create_new_account ? azurerm_automation_account.automation_account[0].name : var.aks_automation.automation_account_name
  aa_resource_group_name  = var.aks_automation.create_new_account ? azurerm_resource_group.default["automation_account"].name : var.aks_automation.resource_group_name

  resource_groups = merge(var.aks_automation.create_new_account ? { "automation_account" = "aa-${data.azurerm_subscription.current.display_name}-${local.virtual_network.location}-${random_string.string.result}" } : {}, { "aks" = "aks-${data.azurerm_subscription.current.display_name}-${local.virtual_network.location}-${random_string.string.result}" })
}
