variable "project_id" {
  description = "project id"
  default     = "isi-labs"
}

variable "region" {
  description = "region"
  default     = "europe-west3"
}

variable "cluster_location" {
  description = "Location (region or zone) of the cluster"
  default     = "europe-west3-c"
}

variable "managed_zone" {
  description = "Google cloud DNS managed zone"
  default     = "isium-de"
}

variable "domain_name" {
  description = "domain name"
  default     = "isium.de"
}

variable "cluster_version_prefix" {
  description = "Version prefix of the cluster"
  ##versions: https://github.com/kubernetes/kubernetes/releases
  default     = "1.29."
}

variable "system_name" {
  description = "number of nodes"
  default     = "dev"
}
variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "base_spot" {
  default     = false
  type        = bool
  description = "Use spot instances on the base system"
}

variable "base_machine_type" {
  default     = "e2-medium"
  description = "machine type for the base system"
}
variable "base_min_node_count" {
  default     = 3
  description = "minimum number of nodes on base node pool"
}

variable "base_max_node_count" {
  default     = 6
  description = "maximum number of nodes on base node pool"
}

variable "workspace_machine_type" {
  default     = "t2d-standard-2"
  description = "machine type for the workspace nodes"
}

variable "workspace_min_node_count" {
  default     = 0
  description = "minimum number of nodes on workspace node pool"
}

variable "workspace_max_node_count" {
  default     = 4
  description = "maximum number of nodes on workspace node pool"
}
