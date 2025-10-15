variable "kubeconfig" {
  type        = string
  description = "Path to your kubeconfig"
  default     = "~/.kube/config"
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

# Optional: only used if you set var.install_ingress_controller = true
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}
