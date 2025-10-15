variable "kubeconfig" {
  type        = string
  description = "Path to your kubeconfig"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Optional kube context"
  default     = null
}

variable "diner_chart_path" {
  type        = string
  description = "Path to diner Helm chart"
  default     = "./charts/diner-app"
}

variable "test_ip" {
  type        = string
  description = "IP for sslip.io (127.0.0.1 or minikube ip)"
  default     = "127.0.0.1"
}

variable "http_nodeport" {
  type        = number
  default     = 30080
}

variable "https_nodeport" {
  type        = number
  default     = 30443
}
