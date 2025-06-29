output "hosted_zone_name" {
  description = "value of the hosted zone name"
  value       = azurerm_dns_zone.dns_zone.name
}

output "hosted_zone_id" {
  description = "value of the hosted zone id"
  value       = azurerm_dns_zone.dns_zone.id
}