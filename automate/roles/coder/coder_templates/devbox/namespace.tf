resource "coder_metadata" "namespace_hide" {
  resource_id = kubernetes_namespace.work-ns.id
  hide = true
}
resource "kubernetes_namespace" "work-ns" {
  metadata {
    name = "${var.workspaces_namespace}-${local.workspace_owner}-${local.workspace_name}"
    labels = {
      "user-namespace" = "1"
    }
  }
}
