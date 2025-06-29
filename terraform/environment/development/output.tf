output "resource_group_name" {
  value = data.azurerm_resource_group.resource_group.name
}

# output "github_client_id" {
#   description = "value of the client id for github authentication"
#   value = module.github_access.client_id
#   sensitive = false
# }

# output "github_tenant_id" {
#   description = "value of the tenant id for github authentication"
#   value = module.github_access.tenant_id
#   sensitive = false
# }

# output "kubernetes_client_id" {
#   description = "value of the client id for kubernetes authentication"
#   value = module.kubernetes_access.client_id
#   sensitive = false
# }

# output "kubernetes_tenant_id" {
#   description = "value of the tenant id for kubernetes authentication"
#   value = module.github_access.tenant_id
#   sensitive = false
# }

output "nginx_ip" {
  description = "value of the public IP gained by the NGINX controller"
  value = module.nginx.nginx_ip
}