
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
  sensitive   = true
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
  sensitive   = true
  description = "The namespace to create workspaces in (must exist prior to creating workspaces)"
}

variable "storage_class" {
  type      = string
  sensitive = true
}

variable "devmode" {
  type      = bool
  sensitive = true
  default   = false
}

variable "aws_default_region" {
  type      = string
  sensitive = true
}

variable "restic_repo_prefix" {
  type      = string
  sensitive = true
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "restic_password_prefix" {
  type      = string
  sensitive = true
}

variable "devbox_image" {
  type      = string
  sensitive = true
}

variable "homedir_disk_size" {
  type      = string
  sensitive = true
}

variable "devbox_mem_limit" {
  type        = number
  sensitive   = true
  description = <<-EOF
  RAM limit in MB for the main container.
  EOF
}

variable "docker_service" {
  type        = bool
  sensitive   = true
  description = <<-EOF
  Start a Docker-in-Docker sidecar container to be to use the Docker CLI.
  EOF
}

variable "docker_mem_limit" {
  type        = number
  sensitive   = true
  description = <<-EOF
  RAM limit in MB for the docker container.
  EOF
}

variable "openvpn_service" {
  type        = bool
  sensitive   = true
  description = <<-EOF
  Start a openvpn sidecar to connect the pod to a vpn.
  EOF
}

variable "backup_service" {
  type        = bool
  sensitive   = true
  description = <<-EOF
  Start a restic sidecar container for backups.
  EOF
}

variable "backup_mem_limit" {
  type        = number
  sensitive   = true
  description = <<-EOF
  RAM limit in MB for the backup container.
  EOF
}

variable "backup_cron" {
  type      = string
  sensitive = true
}

variable "restic_forget_args" {
  type      = string
  sensitive = true
}

variable "restic_storage_type" {
  type      = string
  sensitive = true
}

variable "k8s_server" {
  type      = string
  sensitive = true
}

variable "k8s_ca_cert" {
  type      = string
  sensitive = true
}

variable "k8s_cluster_name" {
  type      = string
  sensitive = true
}

variable "cert_expiration_seconds" {
  type      = number
  sensitive = true
}
