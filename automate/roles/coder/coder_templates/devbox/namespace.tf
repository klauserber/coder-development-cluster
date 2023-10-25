
resource "kubernetes_namespace" "work-ns" {
  metadata {
    name = "${var.workspaces_namespace}-${local.workspace_owner}-${local.workspace_name}"
    labels = {
      "user-namespace" = "1"
    }
  }
}
