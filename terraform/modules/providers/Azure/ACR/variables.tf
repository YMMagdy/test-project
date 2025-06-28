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

variable "acrs" {
  description = "value of the ACRs that needs to be created"
  type = map(object({
    name = string
  }))
}

variable "kubelet_identity" {
  description = "value of the kubelet identity needed for giving pull permission to the cluster"
  type = any
}
