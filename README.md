# terraform-gke-cluster

[![Terraform Validation](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml)
[![Security Scan](https://img.shields.io/badge/security-trivy-1904DA.svg)](https://github.com/aquasecurity/trivy)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.15-623CE4.svg)](https://www.terraform.io)
[![Google Provider](https://img.shields.io/badge/google%20provider-~%3E7.31-4285F4.svg)](https://registry.terraform.io/providers/hashicorp/google/latest)
[![GKE](https://img.shields.io/badge/GKE-RAPID%20channel-34A853.svg)](https://cloud.google.com/kubernetes-engine)

Terraform configuration for a cost-optimised, CIS-hardened GKE cluster on Google Cloud. Auto-detects your active `gcloud` project, zone, and username — no required variables.

## What you get

- **Cost-optimised defaults** — e2-micro nodes, spot instances, 1–3 node autoscaling, pd-standard disks
- **CIS-hardened** — master authorised networks, private nodes, network policy, shielded nodes, disabled legacy metadata endpoints
- **Workload Identity** — pods authenticate to GCP APIs without node-level service account keys
- **Shielded Nodes** — secure boot + integrity monitoring enabled on every node
- **Zero-friction setup** — project, zone, region, and cluster name auto-detected from active `gcloud` config; no required variables
- **Required APIs** enabled automatically on first `terraform apply`

## Repo layout

```
terraform/               # GKE cluster — main Terraform configuration
sample-workloads/
  rock-paper-scissors-game/  # Go web app — Kustomize-based deploy example
  nginx/                     # NGINX smoke test via Helm
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.15
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- GCP project with billing enabled

## Quick Start

```bash
git clone https://github.com/idvoretskyi/terraform-gke-cluster.git
cd terraform-gke-cluster/terraform

gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID

terraform init
terraform apply

gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
  --zone $(terraform output -raw cluster_zone) \
  --project $(terraform output -raw project_id)
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
| `master_authorized_networks` | `0.0.0.0/0` | CIDRs allowed to reach the control plane |
| `enable_private_endpoint` | `false` | Private control-plane endpoint |
| `enable_binary_authorization` | `false` | Binary Authorization |

Full variable reference: [`terraform/variables.tf`](terraform/variables.tf)

> **Security note:** `master_authorized_networks` defaults to `0.0.0.0/0` for convenience. In shared or production environments, restrict this to your office or VPN CIDR.

## Cleanup

```bash
cd terraform
terraform destroy
```

> If `deletion_protection` was set to `true`, set it to `false` and run `terraform apply` before destroying.

## License

[MIT](LICENSE) © 2024-2026 idvoretskyi

<details>
<summary>For contributors</summary>

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false && terraform validate
trivy config .
```

</details>
