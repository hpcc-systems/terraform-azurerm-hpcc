resource "random_integer" "int" {
  min = 1
  max = 3
}

resource "random_string" "string" {
  length  = 4
  special = false
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

# module "naming" {
#   source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
# }

# module "metadata" {
#   source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

#   naming_rules = module.naming.yaml

#   market              = var.metadata.market
#   location            = local.virtual_network.location
#   sre_team            = var.metadata.sre_team
#   environment         = var.metadata.environment
#   product_name        = var.metadata.product_name
#   business_unit       = var.metadata.business_unit
#   product_group       = var.metadata.product_group
#   subscription_type   = var.metadata.subscription_type
#   resource_group_type = var.metadata.resource_group_type
#   subscription_id     = module.subscription.output.subscription_id
#   project             = var.metadata.project
# }

# module "resource_group" {
#   source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

#   unique_name = var.resource_group.unique_name
#   location    = local.virtual_network.location
#   names       = local.names
#   tags        = local.tags
# }

resource "azurerm_resource_group" "default" {
  for_each = local.resource_groups

  name     = each.value
  location = local.virtual_network.location
  tags     = merge({ "owner" = var.admin.name, "owner_email" = var.admin.email }, { "justification" = "default automation account" })
}

resource "kubernetes_secret" "sa_secret" {
  for_each = local.storage_accounts

  metadata {
    name = "${each.key}-azure-secret"
  }

  data = {
    "azurestorageaccountname" = "${each.key}"
    "azurestorageaccountkey"  = "${data.azurerm_storage_account.hpccsa[each.key].primary_access_key}"
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

  name                       = var.hpcc.name
  version                    = var.hpcc.image_version
  chart                      = var.hpcc.remote_chart != null ? "hpcc" : var.hpcc.local_chart
  repository                 = var.hpcc.remote_chart
  create_namespace           = var.hpcc.create_namespace
  namespace                  = var.hpcc.namespace
  atomic                     = var.hpcc.atomic
  recreate_pods              = var.hpcc.recreate_pods
  reuse_values               = var.hpcc.reuse_values
  reset_values               = var.hpcc.reset_values
  force_update               = var.hpcc.force_update
  cleanup_on_fail            = var.hpcc.cleanup_on_fail
  disable_openapi_validation = var.hpcc.disable_openapi_validation
  max_history                = var.hpcc.max_history
  wait                       = var.hpcc.wait
  dependency_update          = var.hpcc.dependency_update
  timeout                    = var.hpcc.timeout
  wait_for_jobs              = var.hpcc.wait_for_jobs
  lint                       = var.hpcc.lint

  values = concat(var.elastic4hpcclogs.enable ? [data.http.elastic4hpcclogs_hpcc_logaccess.request_body] : [], var.hpcc.expose_eclwatch ? [file("${path.root}/values/esp.yaml")] : [],
  [file("${path.root}/values/values-retained-azurefile.yaml")], [for v in var.hpcc.values : file(v)])

  dynamic "set" {
    for_each = var.hpcc.image_root != null ? [1] : []
    content {
      name  = "global.image.root"
      value = var.hpcc.image_root
    }
  }

  dynamic "set" {
    for_each = var.hpcc.image_name != null ? [1] : []
    content {
      name  = "global.image.name"
      value = var.hpcc.image_name
    }
  }

  dynamic "set" {
    for_each = var.hpcc.image_version != null ? [1] : []
    content {
      name  = "global.image.version"
      value = var.hpcc.image_version
    }
  }

  dynamic "set" {
    for_each = can(kubernetes_secret.private_docker_registry[0].metadata[0].name) ? [1] : []
    content {
      name  = "global.image.imagePullSecrets"
      value = kubernetes_secret.private_docker_registry[0].metadata[0].name
    }
  }

  depends_on = [
    helm_release.elastic4hpcclogs,
    helm_release.storage,
    azurerm_kubernetes_cluster.aks
  ]
}

resource "helm_release" "elastic4hpcclogs" {
  count = var.disable_helm || !var.elastic4hpcclogs.enable ? 0 : 1

  name                       = var.elastic4hpcclogs.name
  namespace                  = var.hpcc.namespace
  chart                      = var.elastic4hpcclogs.remote_chart != null ? "elastic4hpcclogs" : var.elastic4hpcclogs.local_chart
  repository                 = var.elastic4hpcclogs.remote_chart
  version                    = var.elastic4hpcclogs.version
  values                     = [for v in var.elastic4hpcclogs.values : file(v)]
  create_namespace           = var.elastic4hpcclogs.create_namespace
  atomic                     = var.elastic4hpcclogs.atomic
  force_update               = var.elastic4hpcclogs.force_update
  recreate_pods              = var.elastic4hpcclogs.recreate_pods
  reuse_values               = var.elastic4hpcclogs.reuse_values
  reset_values               = var.elastic4hpcclogs.reset_values
  cleanup_on_fail            = var.elastic4hpcclogs.cleanup_on_fail
  disable_openapi_validation = var.elastic4hpcclogs.disable_openapi_validation
  wait                       = var.elastic4hpcclogs.wait
  max_history                = var.storage.max_history
  dependency_update          = var.elastic4hpcclogs.dependency_update
  timeout                    = var.elastic4hpcclogs.timeout
  wait_for_jobs              = var.elastic4hpcclogs.wait_for_jobs
  lint                       = var.elastic4hpcclogs.lint

  dynamic "set" {
    for_each = var.elastic4hpcclogs.expose ? [1] : []
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

  name                       = var.storage.name
  chart                      = var.storage.remote_chart != null ? "hpcc-azurefile" : var.storage.local_chart
  repository                 = var.storage.remote_chart
  version                    = var.storage.version
  values                     = concat([local.hpcc_azurefile], [for v in var.storage.values : file(v)])
  create_namespace           = var.storage.create_namespace
  namespace                  = var.storage.namespace
  atomic                     = var.storage.atomic
  force_update               = var.storage.force_update
  recreate_pods              = var.storage.recreate_pods
  reuse_values               = var.storage.reuse_values
  reset_values               = var.storage.reset_values
  cleanup_on_fail            = var.storage.cleanup_on_fail
  disable_openapi_validation = var.storage.disable_openapi_validation
  wait                       = var.storage.wait
  max_history                = var.storage.max_history
  dependency_update          = var.storage.dependency_update
  timeout                    = var.storage.timeout
  wait_for_jobs              = var.storage.wait_for_jobs
  lint                       = var.storage.lint

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "null_resource" "az" {
  count = var.auto_connect ? 1 : 0

  provisioner "local-exec" {
    command     = local.az_command
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }

  triggers = { kubernetes_id = azurerm_kubernetes_cluster.aks.id } //must be run after the Kubernetes cluster is deployed.
}

resource "null_resource" "launch_svc_url" {
  for_each = var.auto_launch_eclwatch && try(helm_release.hpcc[0].status, "") == "deployed" ? local.web_urls : {}

  provisioner "local-exec" {
    command     = local.is_windows_os ? "Start-Process ${each.value}" : "open ${each.value} || xdg-open ${each.value}"
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}
