# terraform-gke-cluster

[![Terraform Validation](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml)
[![Security Scan](https://img.shields.io/badge/security-trivy-1904DA.svg)](https://github.com/aquasecurity/trivy)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.9-623CE4.svg)](https://www.terraform.io)
[![Google Provider](https://img.shields.io/badge/google%20provider-~%3E6.0-4285F4.svg)](https://registry.terraform.io/providers/hashicorp/google/latest)
[![GKE](https://img.shields.io/badge/GKE-RAPID%20channel-34A853.svg)](https://cloud.google.com/kubernetes-engine)

Terraform configuration for a cost-optimised, CIS-hardened GKE cluster on Google Cloud. Auto-detects your active `gcloud` project, zone, and username — no required variables.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.9
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- GCP project with billing enabled

Required APIs are enabled automatically.

## Quick Start

```bash
git clone https://github.com/idvoretskyi/terraform-gke-cluster.git
cd terraform-gke-cluster/terraform

gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID

terraform init
terraform apply -var-file=environments/dev.tfvars

$(terraform output -raw kubeconfig_command)
```

For production:

```bash
terraform apply -var-file=environments/prod.tfvars
```

See [`terraform/environments/`](terraform/environments/) for full variable files.

## Configuration

All variables have sensible defaults. The most commonly overridden ones:

| Variable | Default | Description |
|----------|---------|-------------|
| `project_id` | auto-detected | GCP project ID |
| `environment` | `"dev"` | `dev` / `staging` / `prod` |
| `machine_type` | `"e2-micro"` | Node machine type |
| `min_nodes` / `max_nodes` | `1` / `3` | Autoscaler bounds |
| `enable_spot_instances` | `true` | Spot VMs for cost savings |
| `enable_private_endpoint` | `false` | Private control-plane endpoint |
| `enable_binary_authorization` | `false` | Binary Authorization |

Full variable reference: [`terraform/variables.tf`](terraform/variables.tf)

## dev vs prod

| Feature | dev | prod |
|---------|-----|------|
| Machine type | e2-micro | e2-standard-2 |
| Spot instances | ✅ | ❌ |
| Nodes (min/max) | 1 / 3 | 2 / 10 |
| Private endpoint | ❌ | ✅ |
| Binary Authorization | ❌ | ✅ |

## Validation

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false && terraform validate
trivy config .   # requires trivy
```

## Cleanup

```bash
terraform destroy -var-file=environments/dev.tfvars
```

## License

[MIT](LICENSE) © 2024-2026 idvoretskyi
