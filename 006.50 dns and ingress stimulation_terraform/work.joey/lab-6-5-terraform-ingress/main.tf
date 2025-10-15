locals {
  host       = "diner.${var.test_ip}.sslip.io"
  diner_ns   = "diner-lab"
  ingress_ns = "ingress-nginx"
}

resource "kubernetes_namespace" "diner" {
  metadata { name = local.diner_ns }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = local.ingress_ns
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  set {
    name  = "controller.service.nodePorts.http"
    value = var.http_nodeport
  }
  set {
    name  = "controller.service.nodePorts.https"
    value = var.https_nodeport
  }
}

resource "helm_release" "diner" {
  name       = "diner"
  chart      = var.diner_chart_path
  namespace  = kubernetes_namespace.diner.metadata[0].name

  values = [
    yamlencode({
      replicaCount = 1
      service = {
        type = "ClusterIP"
        port = 80
      }
      ingress = {
        enabled   = true
        className = "nginx"
        annotations = {
          "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
        }
        hosts = [{
          host  = local.host
          paths = [{
            path     = "/"
            pathType = "Prefix"
          }]
        }]
      }
    })
  ]

  depends_on = [helm_release.ingress_nginx]
}

output "test_url" {
  value = "http://${local.host}:${var.http_nodeport}/"
}
