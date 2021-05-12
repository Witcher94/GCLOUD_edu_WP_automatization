#Importing module for output dependencies in VPC-network

variable "ig-wp" {
  type = string
}
variable "heal" {
  type = list
}
#Createing wordpress load-balancer
resource "google_compute_global_address" "wordpress-front" {
  name = "wordpress-front"
}

resource "google_compute_global_forwarding_rule" "https" {
  count      = var.enable_ssl ? 1 : 0
  name       = "${var.name}-https-rule"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = google_compute_global_address.wordpress-front.address
  port_range = "443"
  depends_on = [google_compute_global_address.wordpress-front]
}

resource "google_compute_target_https_proxy" "default" {
  count   = var.enable_ssl ? 1 : 0
  name    = "${var.name}-https-proxy"
  url_map = var.url_map
  ssl_certificates = var.ssl_certificates
}

resource "google_compute_backend_service" "wordpress-backend" {
  backend {
    group           = var.ig-wp
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  name        = "wordpress-backend"
  health_checks = var.heal
}
