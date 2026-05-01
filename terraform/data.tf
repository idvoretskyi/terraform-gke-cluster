# Single external data source — emits all gcloud config properties as JSON.
# The script never fails so `terraform plan` works fully offline.
data "external" "gcloud" {
  program = ["sh", "${path.module}/scripts/gcloud-config.sh"]
}
