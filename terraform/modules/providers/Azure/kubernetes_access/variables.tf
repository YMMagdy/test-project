variable "project_name" {
  description = "value of the project name"
  type = string
}

variable "environment" {
  description = "value of the environment"
  type = string
}

variable "cluster_name" {
  description = "value of the cluster name"
  type = string
}

variable "resource_group_name" {
  description = "value of the resource group name"
  type = string
}

variable "github_repo" {
  description = "value of the github repo for authentication"
  type = string
}

variable "github_repo_branch" {
  description = "value of the github repo branch for authentication"
  type = string
}