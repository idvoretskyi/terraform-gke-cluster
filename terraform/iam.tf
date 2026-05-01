# ── Dedicated node-pool service account ──────────────────────────────────────
# CIS GKE 5.2.1: do not use the default Compute Engine service account.
resource "google_service_account" "node_sa" {
  account_id   = substr("${local.base_name}-node-sa", 0, 28)
  display_name = "GKE node pool SA for ${local.base_name}"
  project      = local.project_id

  depends_on = [google_project_service.apis]
}

# Minimum roles required for GKE node pools.
locals {
  node_sa_roles = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
  ])
}

resource "google_project_iam_member" "node_sa_roles" {
  for_each = local.node_sa_roles

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.node_sa.email}"
}
