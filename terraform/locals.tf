locals {
  project_id = (
    var.project_id != null && var.project_id != ""
    ? var.project_id
    : (
      data.external.gcloud.result.project_id != ""
      ? data.external.gcloud.result.project_id
      : "your-project-id-here"
    )
  )

  zone = (
    data.external.gcloud.result.zone != ""
    ? data.external.gcloud.result.zone
    : "us-central1-a"
  )

  region = (
    data.external.gcloud.result.region != ""
    ? data.external.gcloud.result.region
    : join("-", slice(split("-", local.zone), 0, length(split("-", local.zone)) - 1))
  )

  username = (
    data.external.gcloud.result.username != ""
    ? data.external.gcloud.result.username
    : "user"
  )

  name_suffix = (
    var.cluster_name_suffix != null && var.cluster_name_suffix != ""
    ? var.cluster_name_suffix
    : (
      data.external.gcloud.result.default_cluster != ""
      ? data.external.gcloud.result.default_cluster
      : "gke-cluster"
    )
  )

  base_name = "${local.username}-${local.name_suffix}"

  impersonate_sa = data.external.gcloud.result.impersonate_sa
  quota_project  = data.external.gcloud.result.quota_project == "CURRENT_PROJECT" ? "" : data.external.gcloud.result.quota_project

  workload_pool = "${local.project_id}.svc.id.goog"

  common_labels = merge(
    {
      managed-by = "terraform"
    },
    var.resource_labels
  )
}
