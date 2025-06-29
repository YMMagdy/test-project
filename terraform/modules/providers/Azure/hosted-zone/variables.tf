variable "project_name" {
  description = "value of the project name"
  type = string
}

variable "environment" {
  description = "value of the environment"
  type = string
}

variable "hosted_zone_name" {
  description = "value of the hosted zone name"
  type = string
}

variable "resource_group_name" {
  description = "value of the resource group name"
  type = string
}

variable "subdomains" {
  description = "value of the subdomains created under this hosted zone"
  type = map(
    object({
      name = string
      records = list(string)
      type  = string
      ttl   = number
    })
  )

  validation {
    condition = alltrue([
      for subdomain_key, subdomain_value in var.subdomains:
      subdomain_value.type != "CNAME" || length(subdomain_value.records) == 1 # Assistance
    ])

    error_message = "There must be exactly one entry for the CNAME type of records"
  }
}