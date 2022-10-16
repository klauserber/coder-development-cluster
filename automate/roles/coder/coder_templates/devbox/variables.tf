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

variable "aws_access_key" {
  type        = string
  sensitive   = true
  default     = "NONE"
}

variable "aws_secret_key" {
  type        = string
  sensitive   = true
  default     = "NONE"
}

variable "restic_password_prefix" {
  type        = string
  sensitive   = true
  default     = "NONE"
}

variable "devbox_image" {
  type      = string
  default   = "isi006/code-server-devbox:latest"
  sensitive   = true
}

variable "homedir_disk_size" {
  type      = string
  default   = "10Gi"
  sensitive   = true
}

variable "devbox_mem_limit" {
  type      = number
  default   = 4000
  sensitive   = true
  description = <<-EOF
  RAM limit in MB for the main container.
  EOF
}

variable "docker_service" {
  type      = bool
  default   = true
  sensitive   = true
  description = <<-EOF
  Start a Docker-in-Docker sidecar container to be to use the Docker CLI.
  EOF
}

variable "docker_mem_limit" {
  type      = number
  default   = 2000
  sensitive   = true
  description = <<-EOF
  RAM limit in MB for the docker container.
  EOF
}

variable "openvpn_service" {
  type      = bool
  default   = false
  sensitive   = true
  description = <<-EOF
  Start a openvpn sidecar to connect the pod to a vpn.
  EOF
}

variable "backup_service" {
  type      = bool
  default   = false
  sensitive   = true
  description = <<-EOF
  Start a restic sidecar container for backups.
  EOF
}

variable "backup_mem_limit" {
  type      = number
  default   = 2000
  sensitive   = true
  description = <<-EOF
  RAM limit in MB for the backup container.
  EOF
}

variable "backup_cron" {
  type      = string
  default   = "15 * * * *"
  sensitive   = true
}

variable "restic_forget_args" {
  type      = string
  default   = "--keep-last 12 --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 100 --prune"
  sensitive   = true
}
