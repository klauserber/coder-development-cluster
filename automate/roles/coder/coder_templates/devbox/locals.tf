
locals {
  workspace_name = lower(data.coder_workspace.me.name)
  workspace_owner = lower(data.coder_workspace_owner.owner.name)
  k8s_username = "coder-${local.workspace_owner}-${local.workspace_name}"
  is_admin = (local.workspace_owner == "admin")
}
