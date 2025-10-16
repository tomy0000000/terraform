variable "name" {
  type = string
}

# https://docs.digitalocean.com/platform/regional-availability/
variable "region" {
  # e.g. "sfo3"
  type = string
}

# doctl kubernetes options versions
variable "k8s_version" {
  # e.g. "1.33.1-do.3"
  type    = string
  default = "latest"
}

# https://slugs.do-api.dev/
variable "node_size" {
  # e.g. "s-2vcpu-4gb"
  type = string
}

variable "node_count" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
