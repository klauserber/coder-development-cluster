
provider "google" {
  credentials = file("../../config_default/google-coder-automation.json")
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs
      version = "5.10.0"
    }
  }

  required_version = ">= 1.5.7"
}