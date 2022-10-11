variable "use_kubeconfig" {
  type        = bool
  sensitive   = true
  description = <<-EOF
  Use host kubeconfig? (true/false)
  Set this to false if the Coder host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.
  Set this to true if the Coder host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Coder host.
  EOF
  default     = false
}

variable "workspaces_namespace_prefix" {
  type        = string
  sensitive   = true
  description = "The namespace to create workspaces in (must exist prior to creating workspaces)"
  default     = "coder"
}

variable "storage_class" {
  type        = string
  sensitive   = true
  default     = "standard-rwo"
}

variable "devmode" {
  type      = bool
  sensitive = true
  default   = false
}

variable "aws_default_region" {
  type        = string
  sensitive   = true
  default     = "eu-central-1"
}

variable "restic_repo_prefix" {
  type        = string
  sensitive   = true
  default     = "s3:s3.eu-central-1.wasabisys.com/restic-isium-de"
}

