variable "project_id" {
  description = "GCP project ID. Auto-detected from gcloud if not set."
  type        = string
  default     = null
}

variable "cluster_name_suffix" {
  description = "Suffix for the cluster name. Username is prepended automatically. Defaults to gcloud container/cluster or 'gke-cluster'."
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name used in resource labels."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# ── Node pool ─────────────────────────────────────────────────────────────────

variable "machine_type" {
  description = "Machine type for GKE nodes."
  type        = string
  default     = "e2-micro"
}

variable "min_nodes" {
  description = "Minimum number of nodes in the node pool."
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes in the node pool."
  type        = number
  default     = 3
}

variable "node_pool_disk_size" {
  description = "Boot disk size for nodes (GB)."
  type        = number
  default     = 20
}

variable "node_pool_disk_type" {
  description = "Boot disk type for nodes. One of: pd-standard, pd-balanced, pd-ssd."
  type        = string
  default     = "pd-standard"
}

variable "enable_spot_instances" {
  description = "Use spot (preemptible-class) instances for maximum cost savings."
  type        = bool
  default     = true
}

# ── Cluster ───────────────────────────────────────────────────────────────────

variable "release_channel" {
  description = "GKE release channel. RAPID receives the most recent Kubernetes versions."
  type        = string
  default     = "RAPID"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE."
  }
}

variable "enable_private_cluster" {
  description = "Enable private GKE cluster (private nodes, no public node IPs)."
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private control-plane endpoint. Requires bastion host or VPN."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the cluster control plane. Empty = unrestricted (development only)."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_network_policy" {
  description = "Enable Kubernetes network policy enforcement (CIS 5.6.6)."
  type        = bool
  default     = true
}

variable "rbac_security_group" {
  description = "Google Group email for GKE RBAC (CIS 5.6.7). Must exist before applying. Null = disabled."
  type        = string
  default     = null
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization for container image verification (CIS 5.1.4)."
  type        = bool
  default     = false
}

# ── CIS opt-in encryption ─────────────────────────────────────────────────────

variable "database_encryption_key" {
  description = "KMS key name for application-layer secrets encryption (CIS 5.8.1). Null = Google-managed key."
  type        = string
  default     = null
}

variable "boot_disk_kms_key" {
  description = "KMS key self-link for node boot disk CMEK (CIS 5.3.1). Null = Google-managed key."
  type        = string
  default     = null
}

# ── Labels ────────────────────────────────────────────────────────────────────

variable "resource_labels" {
  description = "Additional resource labels. These override module defaults when keys conflict."
  type        = map(string)
  default     = {}
}
