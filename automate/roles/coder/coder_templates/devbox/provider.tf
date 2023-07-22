terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.11.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22"
    }
  }
}

provider "kubernetes" {
  # Authenticate via ~/.kube/config or a Coder-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}
