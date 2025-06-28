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

variable "default_vm_size" {
  description = "value of the default node pool vm size"
  type        = string
  default     = "standard_b2s"
}

variable "default_node_pool_enable_autoscaling" {
  description = "value of the default node pool enable autoscaling"
  type        = bool
  default     = true
}

variable "default_node_pool_node_count" {
  description = "value of the default node pool node count"
  type        = number
  validation {
    condition     = var.default_node_pool_node_count > 0
    error_message = "The value of the default node pool vm count should be more than 0"
  }
}

variable "default_node_pool_node_max_count" {
  description = "value of the default node pool node count"
  type        = number
  validation {
    condition     = var.default_node_pool_node_max_count < 20
    error_message = "The maximum number of nodes in a pool is 20"
  }
}

variable "default_node_pool_swap_file_space" {
  description = "value of the default node swap file in MBs"
  type        = number
  default     = 1024
}

variable "default_node_pool_disk_size_in_gb" {
  default = 30
  description = "value of the disk size for the default node group"
  type = number
}