output "active_service" {
  value       = local.active_service_name
  description = "Service currently receiving traffic"
}

output "ingress_host" {
  value       = var.host
  description = "HTTP host routed to the active service"
}
