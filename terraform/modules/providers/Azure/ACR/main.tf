data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_container_registry" "acr" {
    for_each = {
      for key , values in var.acrs : key => values   
    }

    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    name = each.value.name
    sku = "Basic"
}

resource "azurerm_role_assignment" "aks_role_assigned" {
  for_each = {
      for key , values in var.acrs : key => values   
  }

  principal_id                     = var.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr[each.key].id
  skip_service_principal_aad_check = true
}