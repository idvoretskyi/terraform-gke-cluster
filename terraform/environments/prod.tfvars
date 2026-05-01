# Production environment — enhanced security, performance-optimised.
# Usage: terraform -chdir=terraform apply -var-file=environments/prod.tfvars

environment         = "prod"
release_channel     = "RAPID"
cluster_name_suffix = "prod-cluster"

# Node pool
machine_type          = "e2-standard-2"
min_nodes             = 2
max_nodes             = 10
node_pool_disk_size   = 50
node_pool_disk_type   = "pd-balanced"
enable_spot_instances = false # regular instances for production stability

# Security — strict
enable_private_cluster      = true
enable_private_endpoint     = true
enable_network_policy       = true
enable_binary_authorization = true

# Restrict to internal / VPN networks; add your office CIDR here.
master_authorized_networks = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "Internal networks"
  },
  {
    cidr_block   = "172.16.0.0/12"
    display_name = "Private networks"
  }
]

resource_labels = {
  team = "platform"
}

# Optional: enable CMEK by uncommenting and providing KMS key names.
# database_encryption_key = "projects/PROJECT/locations/REGION/keyRings/RING/cryptoKeys/KEY"
# boot_disk_kms_key       = "projects/PROJECT/locations/REGION/keyRings/RING/cryptoKeys/KEY"
