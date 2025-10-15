# HTML page for Green
resource "kubernetes_config_map_v1" "green_html" {
  metadata {
    name      = "diner-green-html"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  data = {
    "index.html" = <<-EOT
      <!doctype html>
      <html><head><title>Diner — GREEN</title></head>
      <body style="margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:#0d2f1f;color:#a8ffc9;font-family:Arial">
        <h1 style="font-size:72px">GREEN is serving</h1>
      </body></html>
    EOT
  }
}

resource "kubernetes_deployment_v1" "green" {
  metadata {
    name      = "diner-green"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    labels = {
      app   = "diner"
      color = "green"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app   = "diner"
        color = "green"
      }
    }
    template {
      metadata {
        labels = {
          app   = "diner"
          color = "green"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:1.25"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "web"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path   = "index.html"
            read_only  = true
          }
        }
        volume {
          name = "web"
          config_map {
            name = kubernetes_config_map_v1.green_html.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "green" {
  metadata {
    name      = "diner-green-svc"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    labels = {
      app   = "diner"
      color = "green"
    }
  }
  spec {
    selector = {
      app   = "diner"
      color = "green"
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}
