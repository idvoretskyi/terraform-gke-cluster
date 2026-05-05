# Development environment — cost-optimised, convenient access.
# Usage: terraform -chdir=terraform apply -var-file=environments/dev.tfvars

environment         = "dev"
release_channel     = "RAPID"
cluster_name_suffix = "dev-cluster"

# Node pool
machine_type          = "e2-micro"
min_nodes             = 1
max_nodes             = 3
node_pool_disk_size   = 20
node_pool_disk_type   = "pd-standard"
enable_spot_instances = true

# Security — relaxed for developer convenience
enable_private_cluster      = true
enable_private_endpoint     = false # set true if using bastion/VPN
enable_network_policy       = true
enable_binary_authorization = false

# Allow all networks — development only; tighten for shared envs.
master_authorized_networks = [
  {
    cidr_block   = "0.0.0.0/0"
    display_name = "All networks - development only"
  }
]

resource_labels = {
  team = "development"
}
