locals {
  # map both colors to their service names, pick the active one dynamically
  service_map = {
    blue  = kubernetes_service_v1.blue.metadata[0].name
    green = kubernetes_service_v1.green.metadata[0].name
  }
  active_service_name = local.service_map[var.active_color]
}

resource "kubernetes_ingress_v1" "diner" {
  metadata {
    name      = "diner-ingress"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    annotations = {
      # If you use nginx ingress and want to force HTTPS later:
      # "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = local.active_service_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
