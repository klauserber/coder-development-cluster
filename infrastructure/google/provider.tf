
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
      # ##versions: https://registry.terraform.io/providers/hashicorp/google/latest/docs
      version = "5.20.0"
    }
  }

  # ##versions: https://github.com/hashicorp/terraform/releases
  # Do not update for the time being, switch to opentufo?  
  required_version = ">= 1.5.7"
}