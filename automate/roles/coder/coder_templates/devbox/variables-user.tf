
variable "devbox_image" {
  type      = string
  default   = "isi006/code-server-devbox:latest"
}

variable "homedir_disk_size" {
  type      = string
  default   = "10Gi"
}

variable "devbox_mem_limit" {
  type      = number
  default   = 4000
  description = <<-EOF
  RAM limit in MB for the main container.
  EOF
}

variable "docker_service" {
  type      = bool
  default   = true
  description = <<-EOF
  Start a Docker-in-Docker sidecar container to be to use the Docker CLI.
  EOF
}

variable "docker_mem_limit" {
  type      = number
  default   = 2000
  description = <<-EOF
  RAM limit in MB for the docker container.
  EOF
}

variable "openvpn_service" {
  type      = bool
  default   = false
  description = <<-EOF
  Start a openvpn sidecar to connect the pod to a vpn.
  EOF
}

variable "backup_service" {
  type      = bool
  default   = false
  description = <<-EOF
  Start a restic sidecar container for backups.
  EOF
}

variable "backup_mem_limit" {
  type      = number
  default   = 2000
  description = <<-EOF
  RAM limit in MB for the backup container.
  EOF
}

variable "backup_cron" {
  type      = string
  default   = "15 * * * *"
}

variable "restic_forget_args" {
  type      = string
  default   = "--keep-last 12 --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 100 --prune"
}

variable "restic_password_suffix" {
  type      = string
  default   = "default"
}
