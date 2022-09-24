resource "google_compute_address" "lb_ip_address" {
  name = "${var.system_name}-cluster-lb-ip"
}

resource "google_dns_record_set" "cluster-lb" {
  name = "lb.${var.system_name}.${var.domain_name}."
  type = "A"
  ttl  = 60

  managed_zone = var.managed_zone

  rrdatas = [ google_compute_address.lb_ip_address.address ]
}

resource "google_dns_record_set" "cluster-wildcard" {
  name = "*.${var.system_name}.${var.domain_name}."
  type = "CNAME"
  ttl  = 60

  managed_zone = var.managed_zone

  rrdatas = [ "lb.${var.system_name}.${var.domain_name}." ]
}
