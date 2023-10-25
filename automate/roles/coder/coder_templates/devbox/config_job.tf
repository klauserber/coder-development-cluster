
resource "kubernetes_job" "config" {
  metadata {
    name = "coder-${local.workspace_owner}-${local.workspace_name}"
    namespace = var.workspaces_namespace
  }
  spec {
    ttl_seconds_after_finished = 300
    template {
      metadata {}
      spec {
        service_account_name = "coder"
        container {
          name    = "user-config"
          image   = "isi006/k8s-user-config:latest"

          env {
            name  = "K8S_USER"
            value = local.k8s_username
          }
          env {
            name  = "K8S_CA_CERT"
            value = var.k8s_ca_cert
          }
          env {
            name  = "K8S_SERVER"
            value = var.k8s_server
          }
          env {
            name  = "K8S_CLUSTER_NAME"
            value = var.k8s_cluster_name
          }
          env {
            name  = "K8S_TARGET_NAMESPACE"
            value = var.workspaces_namespace
          }
          env {
            name  = "K8S_TARGET_SECRET"
            value = "${local.k8s_username}-kubeconfig"
          }
          env {
            name  = "K8S_DEFAULT_NAMESPACE"
            value = kubernetes_namespace.work-ns.metadata.0.name
          }
          env {
            name  = "CERT_EXPIRATION_SECONDS"
            value = var.cert_expiration_seconds
          }
          env {
            name  = "ADD_SUBJECT_CONFIG"
            value = "/O=coder-developer"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 2
  }
  wait_for_completion = true
}
