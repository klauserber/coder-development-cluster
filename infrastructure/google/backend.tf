terraform {
  backend "gcs" {
    credentials = "../../config/google-cloud.json"
    bucket  = "tf-state-coder"
    prefix  = var.system_name
  }
}