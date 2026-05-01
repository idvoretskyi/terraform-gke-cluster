provider "google" {
  project = local.project_id
  region  = local.region

  # Pass through gcloud impersonation when auth/impersonate_service_account is set.
  impersonate_service_account = local.impersonate_sa != "" ? local.impersonate_sa : null

  # Pass through billing/quota_project when set.
  billing_project       = local.quota_project != "" ? local.quota_project : null
  user_project_override = local.quota_project != "" ? true : false
}

provider "random" {}
