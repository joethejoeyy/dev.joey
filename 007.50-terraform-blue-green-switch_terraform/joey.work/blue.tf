# HTML page for Blue
resource "kubernetes_config_map_v1" "blue_html" {
  metadata {
    name      = "diner-blue-html"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
  }
  data = {
    "index.html" = <<-EOT
      <!doctype html>
      <html><head><title>Diner — BLUE</title></head>
      <body style="margin:0;display:flex;align-items:center;justify-content:center;height:100vh;background:#0a1a3a;color:#8dd2ff;font-family:Arial">
        <h1 style="font-size:72px">BLUE is serving</h1>
      </body></html>
    EOT
  }
}

resource "kubernetes_deployment_v1" "blue" {
  metadata {
    name      = "diner-blue"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    labels = {
      app   = "diner"
      color = "blue"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app   = "diner"
        color = "blue"
      }
    }
    template {
      metadata {
        labels = {
          app   = "diner"
          color = "blue"
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
            name = kubernetes_config_map_v1.blue_html.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "blue" {
  metadata {
    name      = "diner-blue-svc"
    namespace = kubernetes_namespace_v1.ns.metadata[0].name
    labels = {
      app   = "diner"
      color = "blue"
    }
  }
  spec {
    selector = {
      app   = "diner"
      color = "blue"
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}
