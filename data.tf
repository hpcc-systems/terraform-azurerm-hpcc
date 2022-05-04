data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["security", "cost"]
  filter_by_resource_groups = try([module.resource_group.name, var.storage.storage_account.resource_group_name], [module.resource_group.name])
}

data "http" "host_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

data "azurerm_storage_account" "hpccsa" {
  count = var.storage.default ? 0 : 1

  name                = local.storage_account.name
  resource_group_name = local.storage_account.resource_group_name
}

data "external" "vnet" {
  count   = fileexists("modules/virtual_network/bin/outputs.json") ? 1 : 0
  program = ["python", "modules/virtual_network/bin/run.py"]

  query = {
    data_file = "modules/virtual_network/bin/outputs.json"
  }
}

data "external" "sa" {
  count   = fileexists("modules/storage_account/bin/outputs.json") ? 1 : 0
  program = ["python", "modules/storage_account/bin/run.py"]

  query = {
    data_file = "modules/storage_account/bin/outputs.json"
  }
}

data "http" "elastic4hpcclogs_hpcc_logaccess" {
  
  url = local.elastic4hpcclogs_hpcc_logaccess
}
