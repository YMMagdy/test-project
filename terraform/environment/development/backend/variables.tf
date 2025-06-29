variable "project_name" {
  description = "value of the project name"
  default     = "prj"
}

variable "environment" {
  description = "value of the environment"
  default     = "dev"
}

variable "subscription_id" {
  description = "value of the subscription ID"
  sensitive   = true
}

variable "location" {
  description = "value of the location"
  default     = "eastus"
}