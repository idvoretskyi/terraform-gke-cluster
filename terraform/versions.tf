terraform {
  required_version = ">= 1.15"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.31"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}
