# Optional overrides — all variables are auto-detected from gcloud config.
# Copy to terraform.tfvars or pass with: -var-file=environments/example.tfvars

# project_id          = "my-gcp-project-id"
# cluster_name_suffix = "my-cluster"
# release_channel     = "RAPID"

# machine_type          = "e2-small"   # e2-small is the recommended minimum (e2-micro leaves too little RAM after system pods)
# min_nodes             = 1
# max_nodes             = 1            # Fixed single node — bump to 2 to demo autoscaling (~$7.40/mo worst case)
# node_pool_disk_size   = 20
# node_pool_disk_type   = "pd-standard"
# enable_spot_instances = true

# enable_private_cluster      = false  # true requires Cloud NAT (~$32+/mo), breaking the $10/mo budget
# enable_private_endpoint     = false
# enable_network_policy       = true
# enable_binary_authorization = false

# master_authorized_networks = [
#   { cidr_block = "203.0.113.0/24", display_name = "Office network" }
# ]

# --- Observability (all off by default to stay under $10/mo; enable as needed) ---
# enable_vpc_flow_logs      = false   # CIS 5.6.8 — subnet flow logs; metered per GB
# enable_managed_prometheus = false   # Managed Prometheus; metered per sample
# enable_workload_logging   = false   # Ship app logs to Cloud Logging; metered beyond free tier

# resource_labels = { team = "my-team" }

# CMEK (opt-in, CIS 5.3.1 / 5.8.1)
# database_encryption_key = "projects/P/locations/L/keyRings/R/cryptoKeys/K"
# boot_disk_kms_key       = "projects/P/locations/L/keyRings/R/cryptoKeys/K"

