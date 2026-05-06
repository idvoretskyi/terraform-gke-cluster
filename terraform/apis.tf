locals {
  required_apis = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
  ])
}

resource "google_project_service" "apis" {
  for_each = local.required_apis

  project                    = local.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}
