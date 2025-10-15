variable "namespace" {
  type        = string
  default     = "diner-lab"
  description = "Kubernetes namespace for the lab"
}

variable "host" {
  type        = string
  # Use hosts file mapping if you already use diner.local
  # Otherwise you can keep this and curl with -H "Host: ..." via port-forward
  default     = "diner.local"
  description = "Ingress host name"
}

variable "active_color" {
  type        = string
  description = "Which color gets traffic: blue or green"
  default     = "green"
  validation {
    condition     = contains(["blue","green"], var.active_color)
    error_message = "active_color must be blue or green."
  }
}

variable "install_ingress_controller" {
  type        = bool
  default     = false
  description = "Install ingress-nginx via Helm if you don't already have one"
}
