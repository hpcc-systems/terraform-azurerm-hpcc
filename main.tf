resource "random_integer" "int" {
  min = 1
  max = 3
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
  location            = local.virtual_network.location
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
  location    = local.virtual_network.location
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

resource "kubernetes_secret" "private_docker_registry" {
  count = can(var.registry.server) && can(var.registry.username) && can(var.registry.password) ? 1 : 0
  metadata {
    name = "docker-cfg"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry.server}" = {
          "username" = var.registry.username
          "password" = var.registry.password
          "email"    = var.admin.email
          "auth"     = base64encode("${var.registry.username}:${var.registry.password}")
        }
      }
    })
  }
}

resource "helm_release" "hpcc" {
  count = var.disable_helm ? 0 : 1

  name                       = can(var.hpcc.name) ? var.hpcc.name : "myhpcck8s"
  version                    = can(var.hpcc.version) ? var.hpcc.version : null
  chart                      = can(var.hpcc.remote_chart) ? "hpcc" : var.hpcc.local_chart
  repository                 = can(var.hpcc.remote_chart) ? var.hpcc.remote_chart : null
  create_namespace           = true
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  atomic                     = try(var.hpcc.atomic, false)
  recreate_pods              = try(var.hpcc.recreate_pods, false)
  reuse_values               = try(var.hpcc.reuse_values, false)
  reset_values               = try(var.hpcc.reset_values, false)
  force_update               = try(var.hpcc.force_update, false)
  cleanup_on_fail            = try(var.hpcc.cleanup_on_fail, false)
  disable_openapi_validation = try(var.hpcc.disable_openapi_validation, false)
  max_history                = try(var.hpcc.max_history, 0)
  wait                       = try(var.hpcc.wait, true)
  dependency_update          = try(var.hpcc.dependency_update, false)
  timeout                    = try(var.hpcc.timeout, 900)
  wait_for_jobs              = try(var.hpcc.wait_for_jobs, false)
  lint                       = try(var.hpcc.lint, false)

  values = concat(var.elastic4hpcclogs.enable ? [data.http.elastic4hpcclogs_hpcc_logaccess.body] : [], var.hpcc.expose_eclwatch ? [file("${path.root}/values/esp.yaml")] : [],
  [file("${path.root}/values/values-retained-azurefile.yaml")], try([for v in var.hpcc.values : file(v)], []))

  dynamic "set" {
    for_each = can(var.hpcc.image_root) ? [1] : []
    content {
      name  = "global.image.root"
      value = var.hpcc.image_root
    }
  }

  dynamic "set" {
    for_each = can(var.hpcc.image_name) ? [1] : []
    content {
      name  = "global.image.name"
      value = var.hpcc.image_name
    }
  }

  dynamic "set" {
    for_each = can(var.hpcc.image_version) ? [1] : []
    content {
      name  = "global.image.version"
      value = var.hpcc.image_version
    }
  }

  dynamic "set" {
    for_each = can(var.hpcc.image_root) ? [1] : []
    content {
      name  = "global.image.imagePullSecrets"
      value = kubernetes_secret.private_docker_registry[0].metadata[0].name
    }
  }

  depends_on = [
    helm_release.elastic4hpcclogs,
    helm_release.storage,
    module.kubernetes
  ]
}

resource "helm_release" "elastic4hpcclogs" {
  count = var.disable_helm || !var.elastic4hpcclogs.enable ? 0 : 1

  name                       = can(var.elastic4hpcclogs.name) ? var.elastic4hpcclogs.name : "myelastic4hpcclogs"
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  chart                      = can(var.elastic4hpcclogs.remote_chart) ? "elastic4hpcclogs" : var.elastic4hpcclogs.local_chart
  repository                 = can(var.elastic4hpcclogs.remote_chart) ? var.elastic4hpcclogs.remote_chart : null
  version                    = can(var.elastic4hpcclogs.version) ? var.elastic4hpcclogs.version : null
  values                     = try([for v in var.elastic4hpcclogs.values : file(v)], [])
  create_namespace           = true
  atomic                     = try(var.elastic4hpcclogs.atomic, false)
  force_update               = try(var.elastic4hpcclogs.force_update, false)
  recreate_pods              = try(var.elastic4hpcclogs.recreate_pods, false)
  reuse_values               = try(var.elastic4hpcclogs.reuse_values, false)
  reset_values               = try(var.elastic4hpcclogs.reset_values, false)
  cleanup_on_fail            = try(var.elastic4hpcclogs.cleanup_on_fail, false)
  disable_openapi_validation = try(var.elastic4hpcclogs.disable_openapi_validation, false)
  wait                       = try(var.elastic4hpcclogs.wait, true)
  max_history                = try(var.storage.max_history, 0)
  dependency_update          = try(var.elastic4hpcclogs.dependency_update, false)
  timeout                    = try(var.elastic4hpcclogs.timeout, 300)
  wait_for_jobs              = try(var.elastic4hpcclogs.wait_for_jobs, false)
  lint                       = try(var.elastic4hpcclogs.lint, false)

  dynamic "set" {
    for_each = can(var.elastic4hpcclogs.expose) ? [1] : []
    content {
      type  = "string"
      name  = "kibana.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
      value = tostring(false)
    }
  }

  depends_on = [
    helm_release.storage
  ]
}

resource "helm_release" "storage" {
  count = var.disable_helm ? 0 : 1

  name                       = "azstorage"
  chart                      = can(var.storage.remote_chart) ? "hpcc-azurefile" : var.storage.local_chart
  repository                 = can(var.storage.remote_chart) ? var.storage.remote_chart : null
  version                    = can(var.storage.version) ? var.storage.version : null
  values                     = concat(var.storage.default ? [] : [file("${path.root}/values/hpcc-azurefile.yaml")], try([for v in var.storage.values : file(v)], []))
  create_namespace           = true
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  atomic                     = try(var.storage.atomic, false)
  force_update               = try(var.storage.force_update, false)
  recreate_pods              = try(var.storage.recreate_pods, false)
  reuse_values               = try(var.storage.reuse_values, false)
  reset_values               = try(var.storage.reset_values, false)
  cleanup_on_fail            = try(var.storage.cleanup_on_fail, null)
  disable_openapi_validation = try(var.storage.disable_openapi_validation, false)
  wait                       = try(var.storage.wait, true)
  max_history                = try(var.storage.max_history, 0)
  dependency_update          = try(var.storage.dependency_update, false)
  timeout                    = try(var.storage.timeout, 600)
  wait_for_jobs              = try(var.storage.wait_for_jobs, false)
  lint                       = try(var.storage.lint, false)

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
