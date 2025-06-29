terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

locals {
  resource_group_name    = "${var.project_name}-${var.environment}-rg"
  storage_account_name   = "${var.project_name}${var.environment}${random_string.resource_code.result}tfstate"
  storage_container_name = "${var.project_name}${var.environment}tfstate"

}

resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_group_name
  location = "East US"
}


resource "azurerm_storage_account" "tfstate-storage-account" {
  name                            = lower(local.storage_account_name)
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    created     = "Terraform"
    environment = "${var.environment}"
    project     = "${var.project_name}"
  }
}

resource "azurerm_storage_container" "tfstate-storage-container" {
  name                  = local.storage_container_name
  storage_account_id    = azurerm_storage_account.tfstate-storage-account.id
  container_access_type = "private"
}