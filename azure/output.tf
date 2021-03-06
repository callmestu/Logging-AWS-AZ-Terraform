data "azurerm_log_analytics_workspace" "logAnalytics" {
  name                = "acctest-01"
  resource_group_name = "acctest"
}

output "log_analytics_workspace_id" {
  value = data.azurerm_log_analytics_workspace.logAnalytics.workspace_id
}
