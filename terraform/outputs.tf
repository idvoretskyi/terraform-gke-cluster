output "cluster_name" {
  description = "Name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "Full resource ID of the GKE cluster."
  value       = google_container_cluster.primary.id
}

output "cluster_zone" {
  description = "Zone where the GKE cluster is deployed."
  value       = local.zone
}

output "cluster_region" {
  description = "Region where the GKE cluster is deployed."
  value       = local.region
}

output "cluster_location" {
  description = "Location (zone) returned by the cluster resource."
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "Control-plane endpoint of the GKE cluster."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "master_version" {
  description = "Kubernetes version running on the control plane."
  value       = google_container_cluster.primary.master_version
}

output "node_pool_instance_group_urls" {
  description = "Instance group URLs for the node pool."
  value       = google_container_node_pool.primary_nodes.instance_group_urls
}

output "node_service_account_email" {
  description = "Email of the dedicated node-pool service account."
  value       = google_service_account.node_sa.email
}

output "project_id" {
  description = "GCP project ID in use."
  value       = local.project_id
}

output "kubeconfig_command" {
  description = "Run this command to configure kubectl for the cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${local.project_id}"
}
