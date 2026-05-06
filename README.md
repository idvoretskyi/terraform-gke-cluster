# terraform-gke-cluster

[![Terraform Validation](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml)
[![Security Scan](https://img.shields.io/badge/security-trivy-1904DA.svg)](https://github.com/aquasecurity/trivy)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.15-623CE4.svg)](https://www.terraform.io)
[![Google Provider](https://img.shields.io/badge/google%20provider-~%3E7.31-4285F4.svg)](https://registry.terraform.io/providers/hashicorp/google/latest)
[![GKE](https://img.shields.io/badge/GKE-RAPID%20channel-34A853.svg)](https://cloud.google.com/kubernetes-engine)

Terraform configuration for a cost-optimised, CIS-hardened GKE cluster on Google Cloud. Auto-detects your active `gcloud` project, zone, and username — no required variables.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.15
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
terraform apply

$(terraform output -raw kubeconfig_command)
```

See [`terraform/environments/example.tfvars`](terraform/environments/example.tfvars) for all available overrides.

## Configuration

All variables have sensible defaults. The most commonly overridden ones:

| Variable | Default | Description |
|----------|---------|-------------|
| `project_id` | auto-detected | GCP project ID |
| `machine_type` | `"e2-micro"` | Node machine type |
| `min_nodes` / `max_nodes` | `1` / `3` | Autoscaler bounds |
| `enable_spot_instances` | `true` | Spot VMs for cost savings |
| `master_authorized_networks` | `0.0.0.0/0` | CIDRs allowed to reach control plane — tighten for shared envs |
| `enable_private_endpoint` | `false` | Private control-plane endpoint |
| `enable_binary_authorization` | `false` | Binary Authorization |

Full variable reference: [`terraform/variables.tf`](terraform/variables.tf)

## Validation

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false && terraform validate
trivy config .
```

## Cleanup

```bash
cd terraform
terraform destroy
```

## License

[MIT](LICENSE) © 2024-2026 idvoretskyi
