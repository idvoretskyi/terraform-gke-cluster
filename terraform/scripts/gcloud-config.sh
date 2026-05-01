#!/bin/sh
# Emit a JSON object with every gcloud config property the Terraform module needs.
# Keys are always present; values are empty string when unavailable.
# This script never exits with a non-zero code so `terraform plan` works offline.

safe() {
  # Remove characters that are unsafe in JSON string values (quotes, backslashes, newlines).
  printf '%s' "$1" | tr -d '\n\r\\' | sed "s/\"/'/g"
}

if command -v gcloud >/dev/null 2>&1; then
  PROJECT=$(gcloud config get-value core/project    2>/dev/null || true)
  ZONE=$(gcloud config get-value    compute/zone    2>/dev/null || true)
  REGION=$(gcloud config get-value  compute/region  2>/dev/null || true)
  ACCOUNT=$(gcloud config get-value core/account    2>/dev/null || true)
  CLUSTER=$(gcloud config get-value container/cluster 2>/dev/null || true)
  IMPERSONATE=$(gcloud config get-value auth/impersonate_service_account 2>/dev/null || true)
  QUOTA_PROJECT=$(gcloud config get-value billing/quota_project 2>/dev/null || true)
else
  PROJECT="" ZONE="" REGION="" ACCOUNT="" CLUSTER="" IMPERSONATE="" QUOTA_PROJECT=""
fi

# Derive username from account (part before @), sanitize to [a-z0-9-], truncate to 12 chars.
if [ -n "$ACCOUNT" ]; then
  USERNAME=$(printf '%s' "$ACCOUNT" | cut -d'@' -f1 | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | cut -c1-12 | sed 's/-$//')
else
  USERNAME=$(whoami 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | cut -c1-12 | sed 's/-$//' || echo "user")
fi

printf '{"project_id":"%s","zone":"%s","region":"%s","account":"%s","username":"%s","default_cluster":"%s","impersonate_sa":"%s","quota_project":"%s"}\n' \
  "$(safe "$PROJECT")" \
  "$(safe "$ZONE")" \
  "$(safe "$REGION")" \
  "$(safe "$ACCOUNT")" \
  "$(safe "$USERNAME")" \
  "$(safe "$CLUSTER")" \
  "$(safe "$IMPERSONATE")" \
  "$(safe "$QUOTA_PROJECT")"
