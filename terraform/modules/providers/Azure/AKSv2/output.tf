output "oidc_issuer_url" {
  description = "value of the oidc issuer URL"
  value       = module.aks.oidc_issuer_url
}

output "cluster_host_endpoint" {
  description = "value of the cluster host"
  value       = module.aks.host
}

output "client_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aks.client_certificate
}

output "cluster_ca_certificate" {
  value = module.aks.cluster_ca_certificate
}

output "client_key" {
  value = module.aks.client_key
}

output "kubelet_identity" {
  value = module.aks.kubelet_identity
}

output "cluster_identity" {
  value = module.aks.cluster_identity
  sensitive = true
}

output "aks_name" {
  description = "value of the kubernetes cluster name"
  value       = module.aks.aks_name
}

output "aks_id" {
  description = "value of the kubernetes cluster id"
  value       = module.aks.aks_id
}
