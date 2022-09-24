
provider "google" {
  credentials = file("../../config/google-cloud.json")
  project     = var.project_id
  region      = var.region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.37.0"
    }
  }

  required_version = ">= 1.2.6"
}