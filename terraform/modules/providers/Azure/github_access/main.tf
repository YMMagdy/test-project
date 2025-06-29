data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_container_registry" "acr" {
  for_each = {
        for key, value in var.acr_names : key => value
  }
  name                = each.value.name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}


resource "azuread_application" "github_acr_app" {
  display_name = "github-acr-sp"
}

resource "azuread_service_principal" "github_acr_sp" {
    client_id = azuread_application.github_acr_app.client_id
}

resource "azuread_application_federated_identity_credential" "github_oidc" {  #Assisted
  display_name          = "GitHubOIDC"
  description           = "OIDC federation for GitHub Actions"
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repo}:ref:refs/heads/${var.github_repo_branch}"
  audiences             = ["api://AzureADTokenExchange"]
  application_id        = azuread_application.github_acr_app.id
}

resource "azurerm_role_assignment" "acr_push" {
    for_each = {
        for key, value in data.azurerm_container_registry.acr : key => value
    }
  principal_id         = azuread_service_principal.github_acr_sp.object_id
  role_definition_name = "AcrPush"
  scope                = each.value.id
}