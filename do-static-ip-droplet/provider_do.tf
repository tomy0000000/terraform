terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "droplet_name" {
  description = "Droplet name on DigitalOcean"
  type        = string
}
variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
}
variable "private_key" {
  description = "Raw private key for SSH"
  type        = string
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "default_key" {
  name = "DigitalOcean Key"
}
