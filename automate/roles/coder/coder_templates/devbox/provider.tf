terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      # https://registry.terraform.io/providers/coder/coder/latest/docs
      version = "0.12.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  # Authenticate via ~/.kube/config or a Coder-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}
