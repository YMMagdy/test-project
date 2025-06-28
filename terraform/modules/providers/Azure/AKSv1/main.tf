locals {
  node_count_validation = var.default_node_pool_node_max_count > var.default_node_pool_node_count ? true : false
}


resource "null_resource" "validate_node_count" {
  count = local.node_count_validation ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Validation passed: maximum_node_count < node_count'"
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

data "azurerm_virtual_network" "vnet" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  name                = var.vnet.name
}

data "azurerm_subnet" "aks_subnet_public_a" {
  name                 = "public_a" # or specific subnet name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_subnet" "aks_subnet_public_b" {
  name                 = "public_b" # or specific subnet name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_network_security_group" "security_group" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  name                = var.security_group_name
}

module "aks" {
  source                          = "Azure/aks/azurerm//v4"
  version                         = "10.1.0"
  cluster_name                    = "${var.project_name}${var.environment}aks"
  resource_group_name             = data.azurerm_resource_group.resource_group.name
  location                        = data.azurerm_resource_group.resource_group.location
  kubernetes_version              = "1.33"
  network_plugin                  = "azure"   # In development we could use the kubenet for simplicity
  network_plugin_mode             = "overlay" # Use Azure CNI to provide pods with IPs behind the node's IP which prevents IP exhaustion inside the subnet
  identity_type                   = "SystemAssigned"
  cluster_log_analytics_workspace_name = "${var.project_name}${var.environment}workspacename"
  log_analytics_workspace_enabled = false
  private_cluster_enabled         = false
  prefix                          = "${var.project_name}${var.environment}"
  auto_scaler_profile_expander    = "least-waste"
  interval_before_cluster_update  = "48h"
  log_analytics_workspace_resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  net_profile_service_cidrs       = data.azurerm_subnet.aks_subnet_public_a.address_prefixes
  # dns_prefix_private_cluster      = "${var.project_name}_${var.environment}"
  # node_resource_group             = data.azurerm_resource_group.resource_group.name
  node_network_profile = {
    default_network_profile = {
       application_security_group_ids = ["${data.azurerm_network_security_group.security_group.id}"]
    }
  }
  node_pools = {
    default = {
      name                = "${var.project_name}${var.environment}np"
      node_count          = var.default_node_pool_node_count
      vm_size             = "${var.default_vm_size}"
      enable_auto_scaling = var.default_node_pool_enable_autoscaling
      swap_file_size_mb   = var.default_node_pool_swap_file_space
      max_count           = var.default_node_pool_node_max_count
      min_count           = 1
      os_disk_type        = "Managed"
      os_type             = "Linux"
      load_balancer_sku   = "standard" # For creating a load balancer for the cluster
      vnet_subnet         = { id = data.azurerm_subnet.aks_subnet_public_b.id }
      os_disk_size_gb     = var.default_node_pool_disk_size_in_gb
      node_labels = {
        name                 = "${var.project_name}${var.environment}np"
        vm_size              = "${var.default_vm_size}"
        Owned                = "Terraform"
        NodePool             = "${var.project_name}${var.environment}np"
        auto_scaling_enabled = "${var.default_node_pool_enable_autoscaling}"
      }
    }
  }
  oidc_issuer_enabled = true
}

resource "azurerm_network_security_rule" "aks_node_to_node" {
  name                        = "allow_node_to_node_all"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${data.azurerm_subnet.aks_subnet_public_a.address_prefix}"
  destination_address_prefix  = "${data.azurerm_subnet.aks_subnet_public_a.address_prefix}" # To allow communication between all the nodes inside the node pool
  network_security_group_name = data.azurerm_network_security_group.security_group.name
  resource_group_name         = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "aks_node_egress_all" {
  name                        = "allow_node_egress_all"
  priority                    = 104
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  network_security_group_name = data.azurerm_network_security_group.security_group.name
  resource_group_name         = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "aks_ephemeral_egress_tcp" {
  name                        = "allow_ephemeral_egress_tcp"
  priority                    = 105
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["1025-65535"]
  source_address_prefix       = "${data.azurerm_subnet.aks_subnet_public_a.address_prefix}"
  destination_address_prefix  = "${data.azurerm_subnet.aks_subnet_public_a.address_prefix}" # To allow communication between all the nodes inside the node pool
  network_security_group_name = data.azurerm_network_security_group.security_group.name
  resource_group_name         = data.azurerm_resource_group.resource_group.name
}