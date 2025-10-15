# ------------------------------------------------------
# Canary Weight Variable
# ------------------------------------------------------
variable "canary_weight" {
  type        = number
  default     = 10
  description = "Percentage of traffic routed to canary"
}
