resource "helm_release" "argo_cd" {
    repository = "https://argoproj.github.io/argo-helm"
    name = "argo-cd"
    chart = "argo-cd"
    version = "8.1.2"
    namespace = "argo-cd-dev"
    create_namespace = true

    set {
      name = "global.domain"
      value = "flask-app-example.duckdns.org"
    }

    set {
      name = "server.ingress.enabled"
      value = "true"
    }

    set {
      name = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io\\/backend-protocol"
      value = "HTTPS"
    }

    set {
      name = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io\\/affinity"
      value = "cookie"
    }

    set {
      name = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io\\/secure-backends"
      value = "true"
    }

    set {
      name = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io\\/ssl-redirect"
      value = "false"
    }

    set{
        name = "server.ingress.ingressClassName"
        value = "external-nginx"
    }

}