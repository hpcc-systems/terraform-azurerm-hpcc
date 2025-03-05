resource "azurerm_user_assigned_identity" "aks" {
  count = (var.identity_type == "UserAssigned" && var.user_assigned_identity == null ? 1 : 0)

  resource_group_name = azurerm_resource_group.default["aks"].name
  location            = azurerm_resource_group.default["aks"].location
  name                = local.user_assigned_identity_name
}

resource "azurerm_role_assignment" "subnet_network_contributor" {
  for_each = (local.vnet_ids == null ? {} : (var.configure_network_role ? local.vnet_ids.subnets : {}))

  scope                = each.value.id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity_id
}

resource "azurerm_role_assignment" "route_table_network_contributor" {
  count = (local.vnet_ids == null ? 0 : 1)

  scope                = local.vnet_ids.route_table_id
  role_definition_name = "Network Contributor"
  principal_id = (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks.0.principal_id :
  var.user_assigned_identity.principal_id)
}

resource "azurerm_kubernetes_cluster" "aks" {
  #   depends_on = [azurerm_role_assignment.route_table_network_contributor]

  name                = local.cluster_name
  location            = azurerm_resource_group.default["aks"].location
  resource_group_name = azurerm_resource_group.default["aks"].name
  tags                = local.tags

  sku_tier            = var.sku_tier
  kubernetes_version  = var.kubernetes_version
  node_resource_group = local.node_resource_group
  dns_prefix          = local.dns_prefix != null ? local.dns_prefix : "hpcc-platform"

  private_cluster_enabled = var.private_cluster_enabled

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    dns_service_ip = (var.network_profile_options == null ? null : var.network_profile_options.dns_service_ip)
    service_cidr   = (var.network_profile_options == null ? null : var.network_profile_options.service_cidr)
    outbound_type  = var.outbound_type
    pod_cidr       = (var.network_plugin == "kubenet" ? var.pod_cidr : null)
  }

  default_node_pool {
    name                         = var.default_node_pool
    zones                        = local.node_pools[var.default_node_pool].zones
    vm_size                      = local.node_pools[var.default_node_pool].vm_size
    os_disk_size_gb              = local.node_pools[var.default_node_pool].os_disk_size_gb
    os_disk_type                 = local.node_pools[var.default_node_pool].os_disk_type
    auto_scaling_enabled         = local.node_pools[var.default_node_pool].auto_scaling_enabled
    node_count                   = (local.node_pools[var.default_node_pool].auto_scaling_enabled ? null : local.node_pools[var.default_node_pool].node_count)
    min_count                    = (local.node_pools[var.default_node_pool].auto_scaling_enabled ? local.node_pools[var.default_node_pool].min_count : null)
    max_count                    = (local.node_pools[var.default_node_pool].auto_scaling_enabled ? local.node_pools[var.default_node_pool].max_count : null)
    host_encryption_enabled      = local.node_pools[var.default_node_pool].host_encryption_enabled
    node_public_ip_enabled       = local.node_pools[var.default_node_pool].node_public_ip_enabled
    type                         = local.node_pools[var.default_node_pool].type
    only_critical_addons_enabled = local.node_pools[var.default_node_pool].only_critical_addons_enabled
    orchestrator_version         = local.node_pools[var.default_node_pool].orchestrator_version
    max_pods                     = local.node_pools[var.default_node_pool].max_pods
    node_labels                  = local.node_pools[var.default_node_pool].node_labels
    tags                         = local.node_pools[var.default_node_pool].tags
    vnet_subnet_id = (local.node_pools[var.default_node_pool].subnet != null ?
    local.vnet_ids.subnets[local.node_pools[var.default_node_pool].subnet].id : null)

    upgrade_settings {
      max_surge = local.node_pools[var.default_node_pool].max_surge
    }
  }

  azure_policy_enabled = var.azure_policy_enabled

  dynamic "oms_agent" {
    for_each = (var.log_analytics_workspace_id != null ? [1] : [])
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "windows_profile" {
    for_each = local.windows_nodes ? [1] : []
    content {
      admin_username = var.windows_profile.admin_username
      admin_password = var.windows_profile.admin_password
    }
  }

  identity {
    type = var.identity_type
    identity_ids = (var.identity_type == "SystemAssigned" ? null :
      (var.user_assigned_identity != null ?
        [var.user_assigned_identity.id] :
    [azurerm_user_assigned_identity.aks.0.id]))
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.rbac.enabled ? [1] : []
    content {
      azure_rbac_enabled     = var.rbac.enabled
      admin_group_object_ids = var.rbac.managed ? values(var.rbac_admin_object_ids) : null
    }
  }
}

resource "azurerm_role_assignment" "rbac_admin" {
  for_each             = (var.rbac.enabled ? var.rbac_admin_object_ids : {})
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = local.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  name                    = each.key
  vm_size                 = each.value.vm_size
  os_disk_size_gb         = each.value.os_disk_size_gb
  os_disk_type            = each.value.os_disk_type
  zones                   = each.value.zones
  auto_scaling_enabled    = each.value.auto_scaling_enabled
  node_count              = (each.value.auto_scaling_enabled ? null : each.value.node_count)
  min_count               = (each.value.auto_scaling_enabled ? each.value.min_count : null)
  max_count               = (each.value.auto_scaling_enabled ? each.value.max_count : null)
  os_type                 = each.value.os_type
  host_encryption_enabled = each.value.host_encryption_enabled
  node_public_ip_enabled  = each.value.node_public_ip_enabled
  max_pods                = each.value.max_pods
  node_labels             = each.value.node_labels
  orchestrator_version    = each.value.orchestrator_version
  tags                    = each.value.tags
  vnet_subnet_id = (each.value.subnet != null ?
  local.vnet_ids.subnets[each.value.subnet].id : null)

  node_taints                  = each.value.node_taints
  eviction_policy              = each.value.eviction_policy
  proximity_placement_group_id = each.value.proximity_placement_group_id
  spot_max_price               = each.value.spot_max_price
  priority                     = each.value.priority
  mode                         = each.value.mode

  upgrade_settings {
    max_surge = each.value.max_surge
  }
}
