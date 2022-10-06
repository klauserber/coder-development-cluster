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
  default     = "1.24."
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

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "preemptible" {
  default     = false
  type        = bool
  description = "number of gke nodes"
}
