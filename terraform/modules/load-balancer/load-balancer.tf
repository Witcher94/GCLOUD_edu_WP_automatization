#Importing module for output dependencies in VPC-network

variable "ig-wp" {
  type = string
}
variable "heal" {
  type = list
}


resource "google_compute_global_address" "wordpress-front" {
  name = "wordpress-front"
}

resource "google_compute_global_forwarding_rule" "load-balancer-rule" {
  name                  = "wordpress-forwarding-rule"
  ip_address            = google_compute_global_address.wordpress-front.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
}

resource "google_compute_target_https_proxy" "default" {
  name             = "test-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

resource "google_compute_ssl_certificate" "default" {
  name        = "my-certificate"
  private_key = file("./private.key")
  certificate = file("./certificate.crt")
}

resource "google_compute_url_map" "default" {
  name        = "url-map"
  description = "a description"

  default_service = google_compute_backend_service.wordpress-backend.id

  host_rule {
    hosts        = ["pfaka.pp.ua"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.wordpress-backend.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.wordpress-backend.id
    }
  }
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

output "global-address" {
  value = [google_compute_global_address.wordpress-front.address]
}
