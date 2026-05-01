# terraform-gke-cluster

[![Terraform Validation](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/idvoretskyi/terraform-gke-cluster/actions/workflows/terraform-validate.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.9-623CE4.svg)](https://www.terraform.io)
[![Google Provider](https://img.shields.io/badge/google%20provider-~%3E6.0-4285F4.svg)](https://registry.terraform.io/providers/hashicorp/google/latest)
[![GKE](https://img.shields.io/badge/GKE-RAPID%20channel-34A853.svg)](https://cloud.google.com/kubernetes-engine)

Terraform configuration for a cost-optimised, CIS-hardened GKE cluster on Google Cloud.
Auto-detects your active `gcloud` project, zone, and username — no required variables.

## Features

- **Zero required variables** — project, zone, region, and cluster name derived from `gcloud` config
- **Cost-optimised defaults** — spot instances, e2-micro, 20 GB standard disk, min 1 node
- **RAPID release channel** — always on the latest GKE version
- **CIS GKE Benchmark** — shielded nodes, Workload Identity, private cluster, network policy, VPC flow logs, disabled legacy endpoints
- **Expandable monitoring** — Managed Prometheus + APISERVER / CONTROLLER_MANAGER / SCHEDULER components
- **CMEK opt-in** — database encryption and boot disk KMS keys off by default, easy to enable
- **Parameterised networking** — subnet, pod, and service CIDRs all configurable
- **Dedicated node SA** — minimal IAM roles, no default Compute Engine SA
- **Binary Authorization** — opt-in per environment

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.9 |
| [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) | any recent |
| GCP project | with billing enabled |

Required APIs are enabled automatically by the configuration.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/idvoretskyi/terraform-gke-cluster.git
cd terraform-gke-cluster

# 2. Authenticate
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID   # or pass -var="project_id=..."

# 3. Init & apply (development defaults)
cd terraform
terraform init
terraform apply -var-file=environments/dev.tfvars

# 4. Configure kubectl
$(terraform output -raw kubeconfig_command)
```

### Environment-specific deploys

```bash
# Development — spot instances, public endpoint, RAPID channel
terraform apply -var-file=environments/dev.tfvars

# Production — regular instances, private endpoint, binary auth
terraform apply -var-file=environments/prod.tfvars
```

See [`terraform/environments/`](terraform/environments/) for the full files and comments.

## Configuration

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_id` | `string` | auto-detected | GCP project ID |
| `cluster_name_suffix` | `string` | auto-detected | Suffix appended to username for cluster name |
| `environment` | `string` | `"dev"` | `dev` / `staging` / `prod` — used in labels |
| `deletion_protection` | `bool` | `false` | Prevent accidental cluster deletion |
| `machine_type` | `string` | `"e2-micro"` | Node machine type |
| `min_nodes` | `number` | `1` | Autoscaler minimum |
| `max_nodes` | `number` | `3` | Autoscaler maximum |
| `node_pool_disk_size` | `number` | `20` | Boot disk size (GB) |
| `node_pool_disk_type` | `string` | `"pd-standard"` | `pd-standard` / `pd-balanced` / `pd-ssd` |
| `enable_spot_instances` | `bool` | `true` | Spot VMs for cost savings |
| `release_channel` | `string` | `"RAPID"` | `RAPID` / `REGULAR` / `STABLE` |
| `enable_private_cluster` | `bool` | `true` | Private nodes (no public node IPs) |
| `enable_private_endpoint` | `bool` | `false` | Private control-plane endpoint (needs bastion/VPN) |
| `master_authorized_networks` | `list(object)` | `[]` | CIDRs allowed to reach the API server |
| `enable_network_policy` | `bool` | `true` | Kubernetes network policy (CIS 5.6.6) |
| `rbac_security_group` | `string` | `null` | Google Group email for GKE RBAC (CIS 5.6.7) |
| `enable_binary_authorization` | `bool` | `false` | Binary Authorization (CIS 5.1.4) |
| `subnet_cidr` | `string` | `"10.10.0.0/24"` | Node subnet CIDR |
| `pods_cidr` | `string` | `"10.36.0.0/14"` | Pod alias IP range |
| `services_cidr` | `string` | `"10.40.0.0/20"` | Service cluster IP range |
| `master_ipv4_cidr_block` | `string` | `"172.16.0.32/28"` | Control-plane private CIDR |
| `database_encryption_key` | `string` | `null` | KMS key for secrets encryption (CIS 5.8.1) |
| `boot_disk_kms_key` | `string` | `null` | KMS key for node boot disk CMEK (CIS 5.3.1) |
| `resource_labels` | `map(string)` | `{}` | Extra labels merged onto all resources |

### Outputs

| Output | Sensitive | Description |
|--------|-----------|-------------|
| `cluster_name` | no | GKE cluster name |
| `cluster_id` | no | Full resource ID |
| `cluster_zone` | no | Zone of the cluster |
| `cluster_region` | no | Region of the cluster |
| `cluster_location` | no | Location from cluster resource |
| `cluster_endpoint` | **yes** | Control-plane endpoint |
| `cluster_ca_certificate` | **yes** | Base64-encoded CA cert |
| `master_version` | no | Kubernetes version on the control plane |
| `node_pool_instance_group_urls` | no | Instance group URLs |
| `node_service_account_email` | no | Dedicated node SA email |
| `project_id` | no | GCP project in use |
| `kubeconfig_command` | no | Ready-to-run `gcloud` kubectl config command |

### Auto-detection chain

The module resolves missing values at plan time via a single `gcloud config list` call:

```
project_id   → var.project_id   → gcloud core/project    → "your-project-id-here"
zone         →                    gcloud compute/zone     → "us-central1-a"
region       →                    gcloud compute/region   → derived from zone
username     →                    gcloud account (prefix) → "user"
name_suffix  → var.cluster_name_suffix → gcloud container/cluster → "gke-cluster"
```

`terraform plan` works fully offline; the gcloud script never exits non-zero.

## Environment Comparison

| Feature | dev | prod |
|---------|-----|------|
| Machine type | e2-micro | e2-standard-2 |
| Spot instances | ✅ | ❌ |
| Min / Max nodes | 1 / 3 | 2 / 10 |
| Disk | 20 GB pd-standard | 50 GB pd-balanced |
| Private endpoint | ❌ | ✅ |
| Binary Authorization | ❌ | ✅ |
| Master authorized networks | 0.0.0.0/0 | RFC-1918 only |
| Release channel | RAPID | RAPID |
| deletion_protection | false | true (set manually) |

## CIS GKE Benchmark coverage

| Control | Description | Status |
|---------|-------------|--------|
| CKV_GCP_8 | Legacy metadata endpoints disabled | ✅ |
| CKV_GCP_12 | VPC-native cluster | ✅ |
| CKV_GCP_13 | Client certificate authentication disabled | ✅ |
| CKV_GCP_18 | Private cluster enabled | ✅ |
| CKV_GCP_21 | Resource labels present | ✅ |
| CKV_GCP_25 | Network policy enabled | ✅ |
| CKV_GCP_61 | Workload Identity enabled | ✅ |
| CKV_GCP_65 | Auto-upgrade enabled | ✅ |
| CKV_GCP_66 | Auto-repair enabled | ✅ |
| CKV_GCP_67 | COS_CONTAINERD node image | ✅ |
| CKV_GCP_68 | Secure Boot enabled | ✅ |
| CKV_GCP_69 | Dedicated node SA / GKE_METADATA mode | ✅ |
| CKV_GCP_70 | Shielded GKE nodes | ✅ |
| CKV_GCP_71 | Release channel set | ✅ |
| CKV_GCP_72 | Logging and monitoring enabled | ✅ |

## Local validation

```bash
cd terraform

# Format
terraform fmt -check -recursive

# Validate (no real GCP calls)
terraform init -backend=false
terraform validate

# Security scan (requires checkov)
pip install checkov
checkov -d . --framework terraform
```

## Cleanup

```bash
terraform destroy -var-file=environments/dev.tfvars
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-change`)
3. Commit with sign-off (`git commit -s -m "feat: my change"`)
4. Push and open a pull request against `main`
5. All CI checks must pass

## License

[MIT](LICENSE) © 2024-2026 idvoretskyi
