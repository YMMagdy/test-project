locals {
  node_count_validation = var.default_node_pool_node_max_count > var.default_node_pool_node_count ? true : false
}


resource "null_resource" "validate_node_count" {
  count = local.node_count_validation ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Validation passed: maximum_node_count > node_count'"
  }
}

resource "null_resource" "fail_validation" {
  count = local.node_count_validation ? 0 : 1

  provisioner "local-exec" {
    command = ">&2 echo 'ERROR: maximum_node_count (${var.default_node_pool_node_max_count}) must be more than node_count (${var.default_node_pool_node_count})'; exit 1"
  }
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

module "aks" {
  source                          = "Azure/aks/azurerm//v4"
  version                         = "10.1.0"
  cluster_name                    = "${var.project_name}${var.environment}aks"
  resource_group_name             = data.azurerm_resource_group.resource_group.name
  location                        = data.azurerm_resource_group.resource_group.location
  agents_size                     = "${var.default_vm_size}"
  agents_count                    = "${var.default_node_pool_node_count}" 
  kubernetes_version              = "1.33"
  network_plugin                  = "azure"   # In development we could use the kubenet for simplicity
  network_plugin_mode             = "overlay" # Use Azure CNI to provide pods with IPs behind the node's IP which prevents IP exhaustion inside the subnet
  identity_type                   = "SystemAssigned"
  cluster_log_analytics_workspace_name = "${var.project_name}${var.environment}workspacename"
  log_analytics_workspace_enabled = false
  private_cluster_enabled         = false
  prefix                          = "${var.project_name}${var.environment}"
  auto_scaler_profile_expander    = "least-waste"
  log_analytics_workspace_resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  os_disk_size_gb                 = var.default_node_pool_disk_size_in_gb
  os_disk_type                    = "Managed"
  os_sku                          = "Ubuntu"
  load_balancer_sku               = "standard"
  temporary_name_for_rotation     = "tempnp"
  oidc_issuer_enabled = true
}

