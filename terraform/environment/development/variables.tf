variable "project_name" {
  description = "value of the project name"
  default     = "prj"
}

variable "environment" {
  description = "value of the environment"
  default     = "dev"
}

variable "location" {
  description = "value of the location"
  default     = "eastus"
}

variable "storage_account_name" {
  default = "value of the storage account name"
}

variable "container_name" {
  default = "value of the container name"
}

variable "subscription_id" {
  description = "value of the subscription ID"
  sensitive   = true
}

variable "hosted_zone_domain" {
  description = "value of the hosted zone domain"
  type = string
  default = "duckdns.org"
}

variable "github_repo" {
  description = "value of the github repo for authentication"
  type = string
}

variable "github_repo_branch" {
  description = "value of the github repo branch for authentication"
  type = string
}

