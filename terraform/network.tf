# ── VPC ───────────────────────────────────────────────────────────────────────
resource "google_compute_network" "vpc" {
  name                    = "${local.base_name}-vpc"
  auto_create_subnetworks = false
  project                 = local.project_id

  depends_on = [google_project_service.apis]
}

# ── Subnet ────────────────────────────────────────────────────────────────────
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.base_name}-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = local.region
  network       = google_compute_network.vpc.name
  project       = local.project_id

  private_ip_google_access = true

  # CIS 5.6.8 / VPC Flow Logs
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "10.36.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.40.0.0/20"
  }
}

# ── Firewall: intra-cluster ───────────────────────────────────────────────────
# Allow all traffic within pod CIDR (required for intra-pod communication).
# Tighten the node subnet to GKE control-plane required ports only.
resource "google_compute_firewall" "allow_internal_pods" {
  name        = "${local.base_name}-allow-pods"
  network     = google_compute_network.vpc.name
  project     = local.project_id
  description = "Allow all traffic within the pod CIDR for intra-pod communication."
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.36.0.0/14", "10.40.0.0/20"]
}

resource "google_compute_firewall" "allow_internal_nodes" {
  name        = "${local.base_name}-allow-nodes"
  network     = google_compute_network.vpc.name
  project     = local.project_id
  description = "Allow GKE control-plane required ports within the node subnet."
  direction   = "INGRESS"

  # TCP 443  — Kubernetes API
  # TCP 10250 — kubelet API (required by control plane)
  # ICMP     — health checks and diagnostics
  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/24"]
}
