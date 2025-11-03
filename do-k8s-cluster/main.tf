terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.67"
    }
  }
}

resource "digitalocean_kubernetes_cluster" "the_awesome_cluster" {
  name           = var.name
  region         = var.region
  version        = var.k8s_version
  cluster_subnet = var.cluster_subnet
  service_subnet = var.service_subnet
  tags           = [for key, value in var.tags : "${key}:${value}"]

  node_pool {
    name       = "${var.name}-pool"
    size       = var.node_size
    node_count = var.node_count
    tags       = [for key, value in var.tags : "${key}:${value}"]
  }
}
