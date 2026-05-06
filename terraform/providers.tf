provider "google" {
  project = local.project_id
  region  = local.region

  impersonate_service_account = local.impersonate_sa != "" ? local.impersonate_sa : null

  billing_project       = local.quota_project != "" ? local.quota_project : null
  user_project_override = local.quota_project != "" ? true : false
}

provider "random" {}
