output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}
output "aks_login" {
  value = local.az_command
}
