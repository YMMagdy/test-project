data "azurerm_client_config" "current" {}

output "client_id" {
  description = "value of the client id for github authentication"
  value = azuread_application.github_aks_app.client_id
  sensitive = false
}

output "tenant_id" {
  description = "value of the tenant id for github authentication"
  value = data.azurerm_client_config.current.tenant_id
  sensitive = false
}
