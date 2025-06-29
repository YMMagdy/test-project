output "storage_account_name" {
  value = azurerm_storage_account.tfstate-storage-account.name
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate-storage-container.name
}

