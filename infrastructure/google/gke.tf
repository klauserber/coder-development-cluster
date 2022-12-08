data "google_container_engine_versions" "stable" {
  location       = var.cluster_location
  version_prefix = var.cluster_version_prefix
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.system_name}-gke"
  location = var.cluster_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  # remove_default_node_pool = true
  initial_node_count = 1
  min_master_version = data.google_container_engine_versions.stable.latest_master_version
  node_version       = data.google_container_engine_versions.stable.latest_node_version

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  addons_config {
    network_policy_config {
      disabled = false
    }
  }
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.system_name
    }

    preemptible  = var.preemptible
    machine_type = var.machine_type
    disk_size_gb = 50
    tags         = ["gke-node", "${var.system_name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "secondary_nodes" {
  name     = "${google_container_cluster.primary.name}-node-pool"
  location = var.cluster_location
  cluster  = google_container_cluster.primary.name
  # node_count = var.gke_num_nodes
  version = data.google_container_engine_versions.stable.latest_node_version

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
    location_policy = "ANY"
  }

  initial_node_count = var.min_node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.system_name
    }

    preemptible  = var.preemptible
    machine_type = var.machine_type
    disk_size_gb = 50
    tags         = ["gke-node", "${var.system_name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only.
# # It references the variables and resources provisioned in this file.
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

