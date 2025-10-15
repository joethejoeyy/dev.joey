terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Create a Docker network (like your VPC/VNet)
resource "docker_network" "labnet" {
  name = "phase4-net"
}

# Create a container (like a VM) running nginx
resource "docker_container" "web" {
  name  = "hello-web"
  image = "nginx:latest"

  networks_advanced {
    name = docker_network.labnet.name
  }

  ports {
    internal = 80   # nginx listens inside the container
    external = 8080 # you hit it from your laptop
  }
}

# Output the endpoint
output "web_url" {
  value = "http://localhost:8080"
}
