# locals {
#   subnet_ips = {
#     public_a = {
#       name             = "public_a"
#       address_prefixes = "${var.address_space}.64.0/24"
#     }
#     public_b = {
#       name             = "public_b"
#       address_prefixes = "${var.address_space}.65.0/24"
#     }
#     private_a = {
#       name             = "private_a"
#       address_prefixes = "${var.address_space}.66.0/24"
#     }
#     private_b = {
#       name             = "private_b"
#       address_prefixes = "${var.address_space}.67.0/24"
#     }
#   }
#   cidr = "${var.address_space}.0.0/16"
# }

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_network_security_group" "security_group" {
  name                = "${var.project_name}_${var.environment}_sg"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  tags = {
    environment = "${var.environment}"
    Owner       = "Terraform"
  }
}


resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow_http"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "allow_https"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

locals {
  subnet_ips = {
    public_a = {
      name                   = "public_a"
      address_prefixes       = ["${var.address_space}.64.0/24"]
      network_security_group = { id = azurerm_network_security_group.security_group.id }
    }
    public_b = {
      name                   = "public_b"
      address_prefixes       = ["${var.address_space}.65.0/24"]
      network_security_group = { id = azurerm_network_security_group.security_group.id }
    }
    private_a = {
      name                   = "private_a"
      address_prefixes       = ["${var.address_space}.66.0/24"]
      network_security_group = { id = azurerm_network_security_group.security_group.id }
    }
    private_b = {
      name                   = "private_b"
      address_prefixes       = ["${var.address_space}.67.0/24"]
      network_security_group = { id = azurerm_network_security_group.security_group.id }
    }
  }
  cidr = "${var.address_space}.0.0/16"
}

module "virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = ["${var.address_space}.0.0/16"]
  location            = data.azurerm_resource_group.resource_group.location
  name                = "${var.project_name}_${var.environment}_vnet"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  subnets             = local.subnet_ips
  enable_telemetry    = false

  tags = {
    environment = "${var.environment}"
    Owner       = "Terraform"
  }
}
