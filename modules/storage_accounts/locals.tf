locals {
  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = var.metadata.business_unit
      environment       = var.metadata.environment
      location          = local.location
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
      "owner"       = var.admin.name,
      "owner_email" = var.admin.email,
      "workspace"   = terraform.workspace
    }
    ) : merge(
    module.metadata.tags,
    {
      "owner"       = var.admin.name,
      "owner_email" = var.admin.email,
      "workspace"   = terraform.workspace
    },
    try(var.tags)
  )

  get_vnet_data = fileexists("${path.module}/../virtual_network/bin/vnet.json") ? jsondecode(file("${path.module}/../virtual_network/bin/vnet.json")) : null

  external_vnet = can(var.virtual_network.private_subnet_id) && can(var.virtual_network.public_subnet_id) ? tomap({
    external_private_subnet_id = var.virtual_network.private_subnet_id, external_public_subnet_id = var.virtual_network.public_subnet_id
  }) : null

  internal_vnet = can(local.get_vnet_data) ? tomap({
    internal_private_subnet_id = local.get_vnet_data.private_subnet_id,
    internal_public_subnet_id  = local.get_vnet_data.public_subnet_id
  }) : null

  vnet = merge(local.internal_vnet, local.external_vnet)

  location = can(var.virtual_network.location) ? var.virtual_network.location : local.get_vnet_data.location

  shares = flatten([
    for sa_key, sa_value in var.storage_accounts :
    [
      for share_key, share_value in sa_value.shares :
      {
        name             = "${share_key}"
        quota            = "${share_value.quota}"
        permissions      = "${share_value.permissions}"
        sa_name          = "${module.storage_accounts[sa_key].name}"
        access_tier      = "${share_value.access_tier}"
        enabled_protocol = "${share_value.enabled_protocol}"
        start            = can("${share_value.start}") ? "${share_value.start}" : null
        expiry           = can("${share_value.expiry}") ? "${share_value.expiry}" : null
        sku              = "Standard_${sa_value.replication_type}"
      }
    ]
  ])


  output = templatefile(
    "${path.module}/data_planes.tftpl",
    {
      storage_accounts    = var.storage_accounts,
      random_string       = random_string.random.result,
      resource_group_name = module.resource_group.name
    }
  )
}
