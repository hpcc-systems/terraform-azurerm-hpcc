data "azurerm_subscription" "primary" {}

resource "azurerm_automation_account" "automation_account" {
  name                = var.aks_automation.automation_account_name
  location            = local.virtual_network.location
  resource_group_name = module.resource_group.name
  sku_name            = var.sku_name
  tags                = local.tags
  # local_authentication_enabled  = var.aks_automation.local_authentication_enabled
  public_network_access_enabled = var.aks_automation.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "role_assignment" {
  #scope                = "${data.azurerm_subscription.primary.id}/resourceGroups/${module.resource_group.name}"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.automation_account.identity[0].principal_id
}

resource "azurerm_automation_runbook" "runbook" {
  for_each                = local.runbook
  name                    = each.value.runbook_name
  runbook_type            = each.value.runbook_type
  content                 = local.script[each.value.script_name]
  location                = local.virtual_network.location
  resource_group_name     = module.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  description             = "Runbook for script ${each.value.script_name}"
  log_progress            = var.log_progress
  log_verbose             = var.log_verbose
  tags                    = local.tags
}

resource "azurerm_automation_schedule" "schedule" {
  for_each                = local.schedule
  automation_account_name = azurerm_automation_account.automation_account.name
  description             = each.value.description
  frequency               = each.value.frequency
  interval                = each.value.frequency == "OneTime" ? null : each.value.interval
  month_days              = each.value.frequency != "Month" ? null : each.value.month_days
  week_days               = each.value.frequency != "Week" ? null : each.value.week_days
  name                    = each.value.schedule_name
  resource_group_name     = module.resource_group.name
  # TODO: this assumes the timezone is "America/New_York" and doesn't account for DST - should be fixed
  start_time = length(each.value.start_time) == 5 && contains(["Week", "Month"], each.value.frequency) ? contains(each.value.week_days, local.current_day) && tonumber(substr(each.value.start_time, 0, 2)) >= local.current_hour ? "${local.today}T${each.value.start_time}:15-0${local.utc_offset}:00" : "${local.tomorrow}T${each.value.start_time}:15-0${local.utc_offset}:00" : "${local.today}T${each.value.start_time}:15-0${local.utc_offset}:00"
  timezone   = var.timezone
  #   expiry_time = each.value.expiry_time
}

resource "azurerm_automation_job_schedule" "job_schedule" {
  for_each                = local.schedule
  runbook_name            = azurerm_automation_runbook.runbook[each.value.runbook_name].name
  schedule_name           = azurerm_automation_schedule.schedule[each.value.schedule_name].name
  resource_group_name     = module.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name

  parameters = {
    resourcename      = module.kubernetes.name
    resourcegroupname = module.resource_group.name
    operation         = each.value.operation
    automationaccount = var.aks_automation.automation_account_name
  }
}
