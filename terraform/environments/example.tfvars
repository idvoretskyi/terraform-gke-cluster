# Optional overrides — all variables are auto-detected from gcloud config.
# Copy to terraform.tfvars or pass with: -var-file=environments/example.tfvars

# project_id          = "my-gcp-project-id"
# cluster_name_suffix = "my-cluster"
# release_channel     = "RAPID"

# machine_type          = "e2-micro"
# min_nodes             = 1
# max_nodes             = 3
# node_pool_disk_size   = 20
# node_pool_disk_type   = "pd-standard"
# enable_spot_instances = true

# enable_private_cluster      = true
# enable_private_endpoint     = false
# enable_network_policy       = true
# enable_binary_authorization = false

# master_authorized_networks = [
#   { cidr_block = "203.0.113.0/24", display_name = "Office network" }
# ]

# resource_labels = { team = "my-team" }

# CMEK (opt-in, CIS 5.3.1 / 5.8.1)
# database_encryption_key = "projects/P/locations/L/keyRings/R/cryptoKeys/K"
# boot_disk_kms_key       = "projects/P/locations/L/keyRings/R/cryptoKeys/K"
