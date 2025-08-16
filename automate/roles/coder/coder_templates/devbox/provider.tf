terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      # ##versions: https://registry.terraform.io/providers/coder/coder/latest/docs
      version = "2.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      # ##versions: https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  # Authenticate via ~/.kube/config or a Coder-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}
