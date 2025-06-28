output "vnet" {
  description = "value of the virtual network to be used with other modules"
  value       = module.virtualnetwork.resource
}

output "vnet_id" {
  description = "value of the virtual network id to be used with other modules"
  value       = module.virtualnetwork.resource_id
}

output "subnets" {
  description = "value of the subnets inside the virtual network"
  value       = module.virtualnetwork.subnets
}

output "security_group_name" {
  description = "value of the security group name associated with the vnet"
  value       = azurerm_network_security_group.security_group.name
}