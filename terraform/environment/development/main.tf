locals {
  acrs = {
    flask_container_registry = {
      name = "${var.project_name}${var.environment}flaskrepo"
      }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

data "azurerm_resource_group" "resource_group" {
  name = "${var.project_name}-${var.environment}-rg"
}

# module "network" {
#   source              = "../../modules/providers/Azure/network"
#   project_name        = var.project_name
#   environment         = var.environment
#   resource_group_name = data.azurerm_resource_group.resource_group.name
# }


# module "aksv1" {
#   source                               = "../../modules/providers/Azure/AKSv1"
#   project_name                         = var.project_name
#   environment                          = var.environment
#   vnet                                 = module.network.vnet
#   default_node_pool_enable_autoscaling = true
#   default_node_pool_node_count         = 1
#   default_node_pool_node_max_count     = 10
#   subnets                              = module.network.subnets
#   resource_group_name                  = data.azurerm_resource_group.resource_group.name
#   security_group_name                  = module.network.security_group_name
#   depends_on                           = [module.network]
# }

module "aksv2" {
  source                               = "../../modules/providers/Azure/AKSv2"
  project_name                         = var.project_name
  environment                          = var.environment
  default_node_pool_enable_autoscaling = true
  default_node_pool_node_count         = 2
  default_node_pool_node_max_count     = 10
  resource_group_name                  = data.azurerm_resource_group.resource_group.name
}

module "acr" {
  source = "../../modules/providers/Azure/ACR"
  project_name                         = var.project_name
  environment                          = var.environment
  resource_group_name                  = data.azurerm_resource_group.resource_group.name
  acrs                                 = local.acrs
  kubelet_identity                     = module.aksv2.kubelet_identity 
  depends_on = [ module.aksv2 ]
}

module "github_access" {
  source = "../../modules/providers/Azure/github_access"
  project_name = var.project_name
  environment = var.environment
  resource_group_name = data.azurerm_resource_group.resource_group.name
  acr_names = local.acrs
  github_repo = var.github_repo
  github_repo_branch = var.github_repo_branch
  depends_on = [ module.acr ]
}

module "kubernetes_access" {
  source = "../../modules/providers/Azure/kubernetes_access"
  project_name = var.project_name
  environment = var.environment
  resource_group_name = data.azurerm_resource_group.resource_group.name
  cluster_name = module.aksv2.aks_name
  github_repo = var.github_repo
  github_repo_branch = var.github_repo_branch
  sub_id = var.subscription_id
  depends_on = [ module.aksv2 ]
}

provider "kubernetes" {
    host                   = module.aksv2.cluster_host_endpoint
    cluster_ca_certificate = base64decode(module.aksv2.cluster_ca_certificate)
    client_certificate     = base64decode(module.aksv2.client_certificate)
    client_key             = base64decode(module.aksv2.client_key)
}

provider "helm" {
  kubernetes {
    host                   = module.aksv2.cluster_host_endpoint
    cluster_ca_certificate = base64decode(module.aksv2.cluster_ca_certificate)
    client_certificate     = base64decode(module.aksv2.client_certificate)
    client_key             = base64decode(module.aksv2.client_key)
  }
}


module "nginx" {
  source = "../../modules/providers/Kubernetes/nginx"
  environment = var.environment
  resource_group_name = data.azurerm_resource_group.resource_group.name
  cluster_name = module.aksv2.aks_name
  depends_on = [ module.aksv2 ]
}

module "hosted_zone"{
  source = "../../modules/providers/Azure/hosted-zone"
  environment = var.environment
  resource_group_name = data.azurerm_resource_group.resource_group.name
  project_name = var.project_name
  hosted_zone_name = var.hosted_zone_domain
  subdomains = {
    flask-test = {
      name = "flask-test"
      records = [module.nginx.nginx_ip]
      type = "A"
      ttl = 300
    }

    flask-app-example = {
      name = "flask-app-example"
      records = [module.nginx.nginx_ip]
      type = "A"
      ttl = 300
    }
  }

  depends_on = [ module.aksv2 ]
}

module "argo_cd" {
  source = "../../modules/providers/Kubernetes/ArgoCD"
  environment = var.environment
  depends_on = [ module.aksv2 ]
}
