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

variable "deletion_protection" {
  description = "Prevent accidental cluster deletion. Set to false for dev/test environments."
  type        = bool
  default     = false
}

variable "machine_type" {
  description = "Machine type for GKE nodes."
  type        = string
  default     = "e2-micro"

  validation {
    condition     = length(var.machine_type) > 0
    error_message = "machine_type must not be empty."
  }
}

variable "min_nodes" {
  description = "Minimum number of nodes in the node pool."
  type        = number
  default     = 1

  validation {
    condition     = var.min_nodes >= 1
    error_message = "min_nodes must be at least 1."
  }
}

variable "max_nodes" {
  description = "Maximum number of nodes in the node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.max_nodes >= 1
    error_message = "max_nodes must be at least 1."
  }
}

variable "node_pool_disk_size" {
  description = "Boot disk size for nodes (GB)."
  type        = number
  default     = 20

  validation {
    condition     = var.node_pool_disk_size >= 10
    error_message = "node_pool_disk_size must be at least 10 GB."
  }
}

variable "node_pool_disk_type" {
  description = "Boot disk type for nodes. One of: pd-standard, pd-balanced, pd-ssd."
  type        = string
  default     = "pd-standard"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd"], var.node_pool_disk_type)
    error_message = "node_pool_disk_type must be one of: pd-standard, pd-balanced, pd-ssd."
  }
}

variable "enable_spot_instances" {
  description = "Use spot (preemptible-class) instances for maximum cost savings."
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "GKE release channel."
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
  description = "CIDR blocks allowed to reach the cluster control plane. Defaults to all networks — tighten to your office/VPN CIDR in shared environments."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks — tighten to your CIDR"
    }
  ]
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

variable "subnet_cidr" {
  description = "Primary CIDR range for the node subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for pod IPs (alias IPs)."
  type        = string
  default     = "10.36.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for service cluster IPs."
  type        = string
  default     = "10.40.0.0/20"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE control-plane private endpoint (/28 required)."
  type        = string
  default     = "172.16.0.32/28"
}

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

variable "resource_labels" {
  description = "Additional resource labels. These override module defaults when keys conflict."
  type        = map(string)
  default     = {}
}
