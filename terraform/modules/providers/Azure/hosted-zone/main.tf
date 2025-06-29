data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_dns_zone" "dns_zone" {
  name                = var.hosted_zone_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_dns_a_record" "a_record" {
  for_each = {
    for subdomain_key , subdomain_value in var.subdomains : subdomain_key => subdomain_value
    if subdomain_value.type == "A"   
  }
  
  resource_group_name = data.azurerm_resource_group.resource_group.name
  zone_name = azurerm_dns_zone.dns_zone.name
  name = each.value.name
  ttl = each.value.ttl
  records = each.value.records

  tags = {
    Owned = "Terraform"
    project = "${var.project_name}"
    environment = "${var.environment}"
  }
}

resource "azurerm_dns_cname_record" "cname_record" {
  for_each = {
    for subdomain_key , subdomain_value in var.subdomains : subdomain_key => subdomain_value
    if subdomain_value.type == "CNAME"   
  }
  
  resource_group_name = data.azurerm_resource_group.resource_group.name
  zone_name = azurerm_dns_zone.dns_zone.name
  name = each.value.name
  ttl = each.value.ttl
  record = each.value.records

  tags = {
    Owned = "Terraform"
    project = "${var.project_name}"
    environment = "${var.environment}"
  }
}

resource "azurerm_dns_txt_record" "txt_record" {
  for_each = {
    for subdomain_key , subdomain_value in var.subdomains : subdomain_key => subdomain_value
    if subdomain_value.type == "TXT"   
  }
  
  resource_group_name = data.azurerm_resource_group.resource_group.name
  zone_name = azurerm_dns_zone.dns_zone.name
  name = each.value.name
  ttl = each.value.ttl

  record {
    value = each.value.records.each.value
  }

  tags = {
    Owned = "Terraform"
    project = "${var.project_name}"
    environment = "${var.environment}"
  }
}
