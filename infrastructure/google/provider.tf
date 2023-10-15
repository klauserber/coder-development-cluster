
provider "google" {
  credentials = file("../../config/google-coder-automation.json")
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0"
    }
  }

  required_version = ">= 1.5.3"
}