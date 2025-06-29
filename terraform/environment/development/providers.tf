terraform {
  required_version = ">=1.10.4"

  backend "azurerm" {
    resource_group_name  = "prj-dev-rg"
    storage_account_name = "prjdevrhb64tfstate"
    container_name       = "prjdevtfstate"
    key                  = "prjdev.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "3.4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}
