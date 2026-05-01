locals {
  # ── Project ──────────────────────────────────────────────────────────────────
  # Precedence: variable → gcloud → static fallback.
  project_id = (
    var.project_id != null && var.project_id != ""
    ? var.project_id
    : (
      data.external.gcloud.result.project_id != ""
      ? data.external.gcloud.result.project_id
      : "your-project-id-here"
    )
  )

  # ── Zone & Region ─────────────────────────────────────────────────────────────
  zone = (
    data.external.gcloud.result.zone != ""
    ? data.external.gcloud.result.zone
    : "us-central1-a"
  )

  # Derive region: prefer explicit gcloud region; fallback to stripping zone suffix.
  region = (
    data.external.gcloud.result.region != ""
    ? data.external.gcloud.result.region
    : join("-", slice(split("-", local.zone), 0, length(split("-", local.zone)) - 1))
  )

  # ── Cluster naming ────────────────────────────────────────────────────────────
  # Username is sanitized + truncated to 12 chars by the shell script.
  username = (
    data.external.gcloud.result.username != ""
    ? data.external.gcloud.result.username
    : "user"
  )

  # Suffix: variable → gcloud default cluster → "gke-cluster"
  name_suffix = (
    var.cluster_name_suffix != null && var.cluster_name_suffix != ""
    ? var.cluster_name_suffix
    : (
      data.external.gcloud.result.default_cluster != ""
      ? data.external.gcloud.result.default_cluster
      : "gke-cluster"
    )
  )

  # Base name used for all resources: <username>-<suffix>
  # Full cluster name appends a random suffix: <base>-<random6>
  base_name = "${local.username}-${local.name_suffix}"

  # ── Optional provider features ────────────────────────────────────────────────
  impersonate_sa = data.external.gcloud.result.impersonate_sa
  quota_project  = data.external.gcloud.result.quota_project == "CURRENT_PROJECT" ? "" : data.external.gcloud.result.quota_project

  # ── Workload Identity pool ────────────────────────────────────────────────────
  workload_pool = "${local.project_id}.svc.id.goog"

  # ── Common resource labels ────────────────────────────────────────────────────
  # User-supplied labels take precedence over module defaults.
  common_labels = merge(
    {
      managed-by  = "terraform"
      environment = var.environment
      cost-center = var.environment
    },
    var.resource_labels
  )
}
