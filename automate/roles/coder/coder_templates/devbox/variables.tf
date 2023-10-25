
variable "restic_password_suffix" {
  type        = string
  sensitive   = true
  default     = "default"
  description = <<-EOF
  Password to encrypt the backups. You provide the suffix of the password and we hold the prefix.
  EOF
}

variable "use_kubeconfig" {
  type        = bool
  description = <<-EOF
  Use host kubeconfig? (true/false)
  Set this to false if the Coder host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.
  Set this to true if the Coder host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Coder host.
  EOF
}

variable "workspaces_namespace" {
  type        = string
  description = "The namespace to create workspaces in (must exist prior to creating workspaces)"
}

variable "cluster_public_domain" {
  type        = string
  description = "The domain to use for the Coder installation"
}

variable "storage_class" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "devmode" {
  type    = bool
  default = false
}

variable "aws_default_region" {
  type = string
}

variable "restic_repo_prefix" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "restic_password_prefix" {
  type      = string
  sensitive = true
}

variable "devbox_image" {
  type = string
}

variable "homedir_disk_size" {
  type = string
}

variable "devbox_mem_limit" {
  type        = number
  description = <<-EOF
  RAM limit in MB for the main container.
  EOF
}

variable "docker_service" {
  type        = bool
  description = <<-EOF
  Start a Docker-in-Docker sidecar container to be to use the Docker CLI.
  EOF
}

variable "docker_mem_limit" {
  type        = number
  description = <<-EOF
  RAM limit in MB for the docker container.
  EOF
}

variable "backup_service" {
  type        = bool
  description = <<-EOF
  Start a restic sidecar container for backups.
  EOF
}

variable "backup_mem_limit" {
  type        = number
  description = <<-EOF
  RAM limit in MB for the backup container.
  EOF
}

variable "backup_cron" {
  type = string
}

variable "restic_forget_args" {
  type = string
}

variable "restic_storage_type" {
  type = string
}

variable "k8s_server" {
  type = string
}

variable "k8s_ca_cert" {
  type = string
}

variable "k8s_cluster_name" {
  type = string
}

variable "cert_expiration_seconds" {
  type = number
}

variable "jetbrains_module" {
  type = bool
}
