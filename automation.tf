data "azurerm_subscription" "primary" {}

resource "azurerm_automation_account" "automation_account" {
  count = var.aks_automation.create_new_account ? 1 : 0

  name                          = var.aks_automation.automation_account_name != "aks-automation-default" ? "${var.aks_automation.automation_account_name}-${random_string.string.result}" : "aks-automation-default"
  location                      = local.virtual_network.location
  resource_group_name           = local.aa_resource_group_name
  sku_name                      = var.sku_name
  tags                          = local.tags
  public_network_access_enabled = var.aks_automation.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "role_assignment" {
  count = var.aks_automation.create_new_role_assignment ? 1 : 0

  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = var.aks_automation.create_new_account ? azurerm_automation_account.automation_account[0].identity[0].principal_id : data.azurerm_automation_account.default[0].identity[0].principal_id
}

resource "azurerm_automation_runbook" "runbook" {
  for_each                = local.runbook
  name                    = "${var.admin.name}-${each.value.runbook_name}-${random_string.string.result}"
  runbook_type            = each.value.runbook_type
  content                 = local.script[each.value.script_name]
  location                = local.virtual_network.location
  resource_group_name     = local.aa_resource_group_name
  automation_account_name = local.automation_account_name
  description             = "Runbook for script ${each.value.script_name}"
  log_progress            = var.log_progress
  log_verbose             = var.log_verbose
  tags                    = local.tags
}

resource "azurerm_automation_schedule" "schedule" {
  for_each                = local.schedule
  automation_account_name = local.automation_account_name
  description             = each.value.description
  frequency               = each.value.frequency
  interval                = each.value.frequency == "OneTime" ? null : each.value.interval
  month_days              = each.value.frequency != "Month" ? null : each.value.month_days
  week_days               = each.value.frequency != "Week" ? null : each.value.week_days
  name                    = "${var.admin.name}-${each.value.schedule_name}-${random_string.string.result}"
  resource_group_name     = local.aa_resource_group_name
  start_time              = length(each.value.start_time) == 5 && contains(["Week", "Month"], each.value.frequency) ? contains(each.value.week_days, local.current_day) && tonumber(substr(each.value.start_time, 0, 2)) >= local.current_hour ? "${local.today}T${each.value.start_time}:15-0${local.utc_offset}:00" : "${local.tomorrow}T${each.value.start_time}:15-0${local.utc_offset}:00" : "${local.today}T${each.value.start_time}:15-0${local.utc_offset}:00"
  timezone                = each.value.timezone
  #   expiry_time = each.value.expiry_time
}

resource "azurerm_automation_job_schedule" "job_schedule" {
  for_each                = local.schedule
  runbook_name            = azurerm_automation_runbook.runbook[each.value.runbook_name].name
  schedule_name           = azurerm_automation_schedule.schedule[each.value.schedule_name].name
  resource_group_name     = local.aa_resource_group_name
  automation_account_name = local.automation_account_name

  parameters = {
    resourcename      = azurerm_kubernetes_cluster.aks.name
    resourcegroupname = azurerm_resource_group.default["aks"].name
    operation         = each.value.operation
    automationaccount = var.aks_automation.create_new_account ? "${var.aks_automation.automation_account_name}-${random_string.string.result}" : local.automation_account_name
  }
}
