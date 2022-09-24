
output "ip_address" {
  value = google_compute_address.lb_ip_address.address
}