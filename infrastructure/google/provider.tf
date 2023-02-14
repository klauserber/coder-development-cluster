
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
      version = "4.53.0"
    }
  }

  required_version = ">= 1.2.6"
}