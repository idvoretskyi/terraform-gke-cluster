# ── Node Pool ─────────────────────────────────────────────────────────────────
resource "google_container_node_pool" "primary_nodes" {
  name               = "${local.base_name}-nodes"
  cluster            = google_container_cluster.primary.id
  location           = local.zone
  initial_node_count = var.min_nodes
  project            = local.project_id

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  node_config {
    machine_type    = var.machine_type
    spot            = var.enable_spot_instances
    disk_size_gb    = var.node_pool_disk_size
    disk_type       = var.node_pool_disk_type
    image_type      = "COS_CONTAINERD"                     # CIS 5.5.1: pin to COS with containerd runtime
    service_account = google_service_account.node_sa.email # CIS 5.2.1

    # CIS 5.3.1: CMEK for node boot disks (opt-in; null = Google-managed key)
    boot_disk_kms_key = var.boot_disk_kms_key

    # CIS 5.4.1: disable legacy GCE metadata endpoints
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # CIS 5.2.2: GKE Metadata Server (enables Workload Identity on nodes)
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Minimal OAuth scopes — least privilege. CIS 5.1.3
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    resource_labels = local.common_labels

    # CIS 5.5.6 / 5.5.7: Shielded GKE Node config
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # CIS 5.5.2 / 5.5.3
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [google_service_account.node_sa]
}
