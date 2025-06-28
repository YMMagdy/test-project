variable "location" {
  description = "value of the Azure location"
  default     = "eastus"
  type        = string
}

variable "resource_group_name" {
  description = "value of the resource group name"
  type        = string
}

variable "project_name" {
  description = "value of the project"
  type        = string
}

variable "environment" {
  description = "value of the environment"
  type        = string
}

variable "address_space" {
  description = "value of the first two parts of the address space"
  type        = string
  default     = "172.31"
}