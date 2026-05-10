terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Production must use remote state.
  # backend "gcs" {
  #   bucket = "REPLACE_WITH_TERRAFORM_STATE_BUCKET"
  #   prefix = "terraform/state/prod"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

