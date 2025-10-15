# ------------------------------------------------------
# Terraform Canary Deployment — main.tf (fixed version)
# ------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15"
    }
  }
}

# ------------------------------------------------------
# Providers
# ------------------------------------------------------
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# ------------------------------------------------------
# Helm release — Stable
# ------------------------------------------------------
resource "helm_release" "diner_stable" {
  name       = "diner-stable"
  chart      = "./helm/diner-stable"
  namespace  = "diner-lab"
  create_namespace = true

  values = [
    file("values-stable.yaml")
  ]
}

# ------------------------------------------------------
# Helm release — Canary
# ------------------------------------------------------
resource "helm_release" "diner_canary" {
  name       = "diner-canary"
  chart      = "./helm/diner-canary"
  namespace  = "diner-lab"
  create_namespace = true

  values = [
    templatefile("values-canary.tpl", {
      canary_weight = var.canary_weight
    })
  ]
}


# ------------------------------------------------------
# Outputs
# ------------------------------------------------------
output "diner_canary_weight" {
  value       = var.canary_weight
  description = "Current canary traffic percentage"
}
