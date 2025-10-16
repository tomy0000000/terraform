output "cluster_id" {
  value = digitalocean_kubernetes_cluster.the_awesome_cluster.id
}

output "endpoint" {
  value = digitalocean_kubernetes_cluster.the_awesome_cluster.endpoint
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.the_awesome_cluster.kube_config[0].raw_config
  sensitive = true
}
