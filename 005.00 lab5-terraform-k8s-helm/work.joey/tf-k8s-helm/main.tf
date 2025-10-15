resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
  wait_for_default_service_account = false  # This was in your output, so keeping it
}

resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "15.0.0"  # Pinned version to avoid tag issues (check Bitnami for latest)
  namespace  = kubernetes_namespace.dev.metadata[0].name  # <-- The magic [0] here

  values = [
    file("${path.module}/values/dev.yaml")
  ]
}