data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}


resource "azuread_application" "github_aks_app" {
  display_name = "github-aks-app"
}

resource "azuread_service_principal" "github_aks_app" {
    client_id = azuread_application.github_aks_app.client_id
}

resource "azuread_application_federated_identity_credential" "github_oidc" {  #Assisted
  display_name          = "GitHubOIDC"
  description           = "OIDC federation for GitHub Actions"
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repo}:ref:refs/heads/${var.github_repo_branch}"
  audiences             = ["api://AzureADTokenExchange"]
  application_id        = azuread_application.github_aks_app.id
}

resource "azurerm_role_assignment" "aks_deploy" {
  principal_id         = azuread_service_principal.github_aks_app.object_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope                = data.azurerm_kubernetes_cluster.aks.id
}