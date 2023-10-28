resource "coder_metadata" "user_rb_hide" {
  count = local.is_admin ? 0 : 1
  resource_id = kubernetes_role_binding.namespace_admin.0.id
  hide = true
}

resource "kubernetes_role_binding" "namespace_admin" {
  count = local.is_admin ? 0 : 1
  metadata {
    name      = "coder-namespace-admin"
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "User"
    name      = local.k8s_username
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
}
resource "coder_metadata" "admin_rb_hide" {
  count = local.is_admin ? 1 : 0
  resource_id = kubernetes_cluster_role_binding.cluster_admin.0.id
  hide = true
}

resource "kubernetes_cluster_role_binding" "cluster_admin" {
  count = local.is_admin ? 1 : 0
  metadata {
    name      = "coder-${local.workspace_owner}-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = local.k8s_username
  }
}
