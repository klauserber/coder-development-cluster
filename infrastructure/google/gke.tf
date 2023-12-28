data "google_container_engine_versions" "regular" {
  location       = var.cluster_location
  version_prefix = var.cluster_version_prefix
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.system_name}-gke"
  location = var.cluster_location

  deletion_protection = false

  initial_node_count = 1
  remove_default_node_pool = true
  release_channel {
    channel = "REGULAR"
  }
  min_master_version = data.google_container_engine_versions.regular.latest_master_version

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

}

# Base system node pool
resource "google_container_node_pool" "base_system_nodes" {
  name     = "base"
  location = var.cluster_location
  cluster  = google_container_cluster.primary.name
  version = data.google_container_engine_versions.regular.latest_node_version

  autoscaling {
    min_node_count  = var.base_min_node_count
    max_node_count  = var.base_max_node_count
    location_policy = "ANY"
  }

  initial_node_count = var.base_min_node_count

  node_config {

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.system_name
    }

    spot  = var.base_spot
    machine_type = var.base_machine_type
    disk_size_gb = 50
    tags         = ["gke-node", "${var.system_name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

}

# Node spot pool for workspaces
resource "google_container_node_pool" "workspace_spot_nodes" {
  name     = "workspace-spot"
  location = var.cluster_location
  cluster  = google_container_cluster.primary.name
  # node_count = var.gke_num_nodes
  version = data.google_container_engine_versions.regular.latest_node_version

  autoscaling {
    min_node_count  = var.workspace_min_node_count
    max_node_count  = var.workspace_max_node_count
    location_policy = "ANY"
  }

  initial_node_count = var.workspace_min_node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      "coder-development-cluster/env" = var.system_name
      "coder-development-cluster/workspace" = "true"
    }

    taint {
      key    = "coder-development-cluster/workspace"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    spot = true
    machine_type = var.workspace_machine_type
    disk_size_gb = 50
    tags         = ["gke-node", "${var.system_name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Node regular pool for workspaces
resource "google_container_node_pool" "workspace_nodes" {
  name     = "workspace"
  location = var.cluster_location
  cluster  = google_container_cluster.primary.name
  # node_count = var.gke_num_nodes
  version = data.google_container_engine_versions.regular.latest_node_version

  autoscaling {
    min_node_count  = var.workspace_min_node_count
    max_node_count  = var.workspace_max_node_count
    location_policy = "ANY"
  }

  initial_node_count = var.workspace_min_node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      "coder-development-cluster/env" = var.system_name
      "coder-development-cluster/workspace" = "true"
    }

    taint {
      key    = "coder-development-cluster/workspace"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    machine_type = var.workspace_machine_type
    disk_size_gb = 50
    tags         = ["gke-node", "${var.system_name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
