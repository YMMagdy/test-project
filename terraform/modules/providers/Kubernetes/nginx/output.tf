output "nginx_ip" {
  description = "value of the public IP gained by the NGINX controller"
  value = data.kubernetes_service.nginx_service.status.0.load_balancer.0.ingress.0.ip #Assistance
}