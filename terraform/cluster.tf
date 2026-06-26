resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "google_container_cluster" "primary" {
  name     = "${local.base_name}-${random_string.suffix.result}"
  location = local.zone
  project  = local.project_id

  deletion_protection = var.deletion_protection

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  release_channel {
    channel = var.release_channel
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_secure_boot          = false # bootstrap node only; actual node pool uses true (node_pool.tf)
      enable_integrity_monitoring = true
    }
  }

  resource_labels = {
    managed-by = "terraform"
  }

  # CIS 5.6.1
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "services-range"
  }

  # CIS 5.6.3 / 5.6.4
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # CIS 5.6.2
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # CIS 5.6.6
  dynamic "network_policy" {
    for_each = var.enable_network_policy ? [1] : []
    content {
      enabled = true
    }
  }

  enable_intranode_visibility = true

  # CIS 5.2.2
  workload_identity_config {
    workload_pool = local.workload_pool
  }

  # CIS 5.5.5
  enable_shielded_nodes = true

  # CIS 5.6.8
  logging_config {
    enable_components = compact([
      "SYSTEM_COMPONENTS",
      var.enable_workload_logging ? "WORKLOADS" : "",
    ])
  }

  # CIS 5.6.9
  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER",
    ]

    managed_prometheus {
      enabled = var.enable_managed_prometheus
    }
  }

  # CIS 5.7.2
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # CIS 5.1.4
  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # CIS 5.6.7 / 5.8.2
  dynamic "authenticator_groups_config" {
    for_each = var.rbac_security_group != null ? [1] : []
    content {
      security_group = var.rbac_security_group
    }
  }

  cluster_autoscaling {
    enabled = false
  }

  # CIS 5.8.1
  dynamic "database_encryption" {
    for_each = var.database_encryption_key != null ? [1] : []
    content {
      state    = "ENCRYPTED"
      key_name = var.database_encryption_key
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = "2025-01-01T02:00:00Z"
      end_time   = "2025-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE"
    }
  }

  depends_on = [
    google_project_service.apis,
    google_compute_subnetwork.subnet,
  ]
}
