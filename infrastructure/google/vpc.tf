
# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.system_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.system_name}-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.name
  private_ip_google_access = true
  ip_cidr_range            = "10.55.0.0/24"
}

resource "google_compute_firewall" "nodeports" {
  name    = "${var.system_name}-rule-nodeports"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}