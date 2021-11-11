resource "random_string" "random" {
  length  = 43
  upper   = false
  number  = false
  special = false
}

resource "random_password" "admin" {
  length  = 6
  special = true
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  naming_rules = module.naming.yaml

  market              = var.metadata.market
  location            = local.resource_group.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = module.subscription.output.subscription_id
  project             = var.metadata.project
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  unique_name = var.resource_group.unique_name
  location    = local.resource_group.location
  names       = local.names
  tags        = local.tags
}

module "kubernetes" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v4.2.1"

  cluster_name        = local.cluster_name
  location            = module.resource_group.location
  names               = local.names
  tags                = local.tags
  resource_group_name = module.resource_group.name
  identity_type       = "UserAssigned" # Allowed values: UserAssigned or SystemAssigned

  rbac = {
    enabled        = false
    ad_integration = false
  }

  network_plugin         = "azure"
  configure_network_role = true

  virtual_network = {
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

  node_pools = var.node_pools

  default_node_pool = "system" //name of the sub-key, which is the default node pool.

}

resource "kubernetes_secret" "sa_secret" {
  count = var.storage.default ? 0 : 1

  metadata {
    name = "azure-secret"
  }

  data = {
    "azurestorageaccountname" = local.storage_account.name
    "azurestorageaccountkey"  = data.azurerm_storage_account.hpccsa[0].primary_access_key
  }

  type = "Opaque"
}

resource "helm_release" "hpcc" {
  count = var.disable_helm ? 0 : 1

  name                       = var.hpcc.name
  chart                      = local.hpcc_chart
  create_namespace           = true
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  atomic                     = try(var.hpcc.atomic, null)
  recreate_pods              = try(var.hpcc.recreate_pods, null)
  cleanup_on_fail            = try(var.hpcc.cleanup_on_fail, null)
  disable_openapi_validation = try(var.hpcc.disable_openapi_validation, null)
  wait                       = try(var.hpcc.wait, null)
  dependency_update          = try(var.hpcc.dependency_update, null)
  timeout                    = try(var.hpcc.timeout, 900)
  wait_for_jobs              = try(var.hpcc.wait_for_jobs, null)
  lint                       = try(var.hpcc.lint, null)

  values = concat(var.expose_services ? [file("${path.root}/values/esp.yaml")] : [],
  try([for v in var.hpcc.values : file(v)], []), [file("${path.root}/values/values-retained-azurefile.yaml")])

  dynamic "set" {
    for_each = var.image_root != "" && var.image_root != null ? [1] : []
    content {
      name  = "global.image.root"
      value = var.image_root
    }
  }

  dynamic "set" {
    for_each = var.image_name != "" && var.image_name != null ? [1] : []
    content {
      name  = "global.image.name"
      value = var.image_name
    }
  }

  dynamic "set" {
    for_each = var.image_version != "" && var.image_version != null ? [1] : []
    content {
      name  = "global.image.version"
      value = var.image_version
    }

  }

  depends_on = [helm_release.storage, module.kubernetes]
}

resource "helm_release" "elk" {
  count = var.disable_helm || !var.elk.enable ? 0 : 1

  name                       = var.elk.name
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  chart                      = local.elk_chart
  values                     = concat(try([for v in var.elk.values : file(v)], []), var.expose_services ? [file("${path.root}/values/elk.yaml")] : [])
  create_namespace           = true
  atomic                     = try(var.elk.atomic, null)
  recreate_pods              = try(var.elk.recreate_pods, null)
  cleanup_on_fail            = try(var.elk.cleanup_on_fail, null)
  disable_openapi_validation = try(var.elk.disable_openapi_validation, null)
  wait                       = try(var.elk.wait, null)
  dependency_update          = try(var.elk.dependency_update, null)
  timeout                    = try(var.elk.timeout, 600)
  wait_for_jobs              = try(var.elk.wait_for_jobs, null)
  lint                       = try(var.elk.lint, null)
}

resource "helm_release" "storage" {
  count = var.disable_helm ? 0 : 1

  name                       = "azstorage"
  chart                      = local.storage_chart
  values                     = concat(can(var.storage.storage_account.name) ? [file("${path.root}/values/hpcc-azurefile.yaml")] : [], try([for v in var.storage.values : file(v)], []))
  create_namespace           = true
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  atomic                     = try(var.storage.atomic, null)
  recreate_pods              = try(var.storage.recreate_pods, null)
  cleanup_on_fail            = try(var.storage.cleanup_on_fail, null)
  disable_openapi_validation = try(var.storage.disable_openapi_validation, null)
  wait                       = try(var.storage.wait, null)
  dependency_update          = try(var.storage.dependency_update, null)
  timeout                    = try(var.storage.timeout, 600)
  wait_for_jobs              = try(var.storage.wait_for_jobs, null)
  lint                       = try(var.storage.lint, null)

  depends_on = [
    module.kubernetes
  ]
}

resource "null_resource" "az" {
  count = var.auto_connect ? 1 : 0

  provisioner "local-exec" {
    command     = local.az_command
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }

  triggers = { kubernetes_id = module.kubernetes.id } //must be run after the Kubernetes cluster is deployed.
}

resource "null_resource" "launch_svc_url" {
  for_each = var.auto_launch_eclwatch && try(helm_release.hpcc[0].status, "") == "deployed" ? local.web_urls : {}

  provisioner "local-exec" {
    command     = local.is_windows_os ? "Start-Process ${each.value}" : "open ${each.value} || xdg-open ${each.value}"
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}
