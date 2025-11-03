variable "name" {
  type        = string
  description = "The name of the Kubernetes cluster. The node pool will be named `<name>-pool`."
}

variable "region" {
  type        = string
  description = "The region where the cluster will be created, See [list of all regions](https://docs.digitalocean.com/platform/regional-availability/). e.g. `sfo3`"
}

variable "k8s_version" {
  type        = string
  description = "Use `doctl kubernetes options versions` to findout what versions are supported. e.g. `1.33.1-do.3`."
  default     = "latest"
}

# 
variable "cluster_subnet" {
  type        = string
  default     = "192.168.0.0/16" # Up to 512 nodes
  description = "The CIDR block for the cluster network. This affects the maximum number of nodes that can be created in the cluster. See [this docs](https://docs.digitalocean.com/products/kubernetes/how-to/create-clusters/#create-a-cluster-with-vpc-native-networking)"
}

variable "service_subnet" {
  type        = string
  default     = "172.16.0.0/19" # Up to 8192 services
  description = "The CIDR block for the service network. This affects the maximum number of services that can be created in the cluster. See [this docs](https://docs.digitalocean.com/products/kubernetes/how-to/create-clusters/#create-a-cluster-with-vpc-native-networking)"
}

variable "node_size" {
  type        = string
  description = "The specification of the nodes. e.g. `s-2vcpu-4gb` See [list of all sizes](https://slugs.do-api.dev/)"
}

variable "node_count" {
  type        = number
  description = "The number of nodes to create in the default node pool"
}

variable "tags" {
  type    = map(string)
  default = {}
}
