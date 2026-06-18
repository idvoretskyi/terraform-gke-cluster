resource "google_compute_network" "vpc" {
  name                    = "${local.base_name}-vpc"
  auto_create_subnetworks = false
  project                 = local.project_id

  depends_on = [google_project_service.apis]
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.base_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = local.region
  network       = google_compute_network.vpc.name
  project       = local.project_id

  private_ip_google_access = true

  # CIS 5.6.8 — opt-in; disabled by default to avoid metered ingestion cost.
  # Enable by setting enable_vpc_flow_logs = true.
  dynamic "log_config" {
    for_each = var.enable_vpc_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_cidr
  }
}

# Allow all traffic within pod/service CIDRs for intra-pod communication.
# Source ranges are scoped to pod and service CIDRs only — not the internet.
# Wide TCP/UDP port range is required for arbitrary inter-pod communication;
# narrowing would break workloads. Source CIDR scoping is the security boundary.
# Findings GCP0072/GCP0074 suppressed in .trivyignore with rationale.
resource "google_compute_firewall" "allow_internal_pods" {
  name        = "${local.base_name}-allow-pods"
  network     = google_compute_network.vpc.name
  project     = local.project_id
  description = "Allow all traffic within the pod/service CIDRs for intra-pod communication."
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.pods_cidr, var.services_cidr]
}

resource "google_compute_firewall" "allow_internal_nodes" {
  name        = "${local.base_name}-allow-nodes"
  network     = google_compute_network.vpc.name
  project     = local.project_id
  description = "Allow GKE control-plane required ports within the node subnet."
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}
