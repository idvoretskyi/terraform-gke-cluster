data "external" "gcloud" {
  program = ["sh", "${path.module}/scripts/gcloud-config.sh"]
}
