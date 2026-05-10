terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # For a real team setup, configure a remote backend.
  # backend "gcs" {
  #   bucket = "REPLACE_WITH_TERRAFORM_STATE_BUCKET"
  #   prefix = "terraform/state/dev"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

