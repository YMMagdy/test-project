resource "helm_release" "nginx" {
  name = "nginx-ingress-external-${var.environment}"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = "${var.environment}"
  create_namespace = true

  set {
    name = "controller.ingressClass"
    value = "nginx"
  }

  set {
    name = "controller.ingressClassResource.name"
    value = "external-nginx"
  }

  set {
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

}

data "kubernetes_service" "nginx_service" {
  metadata {
    name = "nginx-ingress-external-${var.environment}-ingress-nginx-controller"
    namespace = "${var.environment}"
  }
  depends_on = [ helm_release.nginx ]
}