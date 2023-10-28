resource "coder_metadata" "pvc_hide" {
  resource_id = kubernetes_persistent_volume_claim.pvc.id
  hide = true
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "coder-${local.workspace_owner}-${local.workspace_name}"
    namespace = var.workspaces_namespace
    labels = {
      "app.kubernetes.io/name"     = "coder-pvc"
      "app.kubernetes.io/instance" = "coder-pvc-${local.workspace_owner}-${local.workspace_name}"
      "app.kubernetes.io/part-of"  = "coder"
      //Coder-specific labels.
      "com.coder.resource"       = "true"
      "com.coder.workspace.id"   = data.coder_workspace.me.id
      "com.coder.workspace.name" = data.coder_workspace.me.name
      "com.coder.user.id"        = data.coder_workspace.me.owner_id
      "com.coder.user.username"  = data.coder_workspace.me.owner
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.homedir_disk_size
      }
    }
    storage_class_name = var.storage_class
  }
}
