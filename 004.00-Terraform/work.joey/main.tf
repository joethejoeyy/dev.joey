terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Network (VPC equivalent)
resource "docker_network" "devops_net" {
  name = "devops_net"
}

# Pull nginx image
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# Run container in that network
resource "docker_container" "web" {
  name  = "web-server"
  image = docker_image.nginx.name
  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.devops_net.name
  }
}
