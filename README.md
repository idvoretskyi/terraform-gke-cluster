# terraform-gke-cluster

[![Terraform Validation](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml)
[![Security Scan](https://img.shields.io/badge/security-trivy-1904DA.svg)](https://github.com/aquasecurity/trivy)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.15-623CE4.svg)](https://www.terraform.io)
[![Google Provider](https://img.shields.io/badge/google%20provider-~%3E7.31-4285F4.svg)](https://registry.terraform.io/providers/hashicorp/google/latest)
[![GKE](https://img.shields.io/badge/GKE-RAPID%20channel-34A853.svg)](https://cloud.google.com/kubernetes-engine)

Terraform configuration for a cost-optimised, CIS-hardened GKE cluster on Google Cloud. Auto-detects your active `gcloud` project, zone, and username — no required variables.

## What you get

- **~$4.50/mo** — single e2-small spot node, pd-standard disk, minimal observability; zonal control plane is free under GKE's one-free-cluster-per-billing-account tier
- **CIS-hardened** — master authorised networks, network policy, shielded nodes with secure boot + integrity monitoring, disabled legacy metadata endpoints
- **Workload Identity** — pods authenticate to GCP APIs without node-level service account keys
- **Zero-friction setup** — project, zone, region, and cluster name auto-detected from active `gcloud` config; required APIs enabled on first `terraform apply`

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
| `machine_type` | `"e2-small"` | Node machine type (recommended minimum) |
| `min_nodes` / `max_nodes` | `1` / `1` | Fixed single node; set `max_nodes = 2` to demo autoscaling |
| `enable_spot_instances` | `true` | Spot VMs for ~70% cost savings |
| `enable_private_cluster` | `false` | Private nodes; requires Cloud NAT (~$32+/mo) |
| `master_authorized_networks` | `0.0.0.0/0` | CIDRs allowed to reach the control plane |
| `enable_private_endpoint` | `false` | Private control-plane endpoint |
| `enable_binary_authorization` | `false` | Binary Authorization |
| `enable_vpc_flow_logs` | `false` | Subnet flow logs (CIS 5.6.8); metered, opt-in |
| `enable_managed_prometheus` | `false` | Managed Prometheus; metered, opt-in |
| `enable_workload_logging` | `false` | Workload log ingestion; metered, opt-in |

Full variable reference: [`terraform/variables.tf`](terraform/variables.tf)

> **Security note:** nodes are public by default (no Cloud NAT cost), making `master_authorized_networks` the primary access control for the control plane — restrict it to your office or VPN CIDR in any shared or persistent environment. Set `enable_private_cluster = true` and add a Cloud NAT resource to restore private nodes.

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
