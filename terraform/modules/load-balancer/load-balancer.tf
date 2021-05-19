resource "google_compute_global_address" "wordpress-front" {
  name = "wordpress-front"
}

resource "google_compute_global_forwarding_rule" "load-balancer-rule" {
  name                  = "wordpress-forwarding-rule"
  ip_address            = google_compute_global_address.wordpress-front.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.httpsProxy.id
}

resource "google_compute_target_https_proxy" "httpsProxy" {
  name             = "test-proxy"
  url_map          = google_compute_url_map.url-map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.sslCertificate.id]
}

resource "google_compute_region_ssl_certificate" "sslCertificate" {
  name_prefix = "wp-certificate"
  description = "provided by terraform"
  private_key = file("~/Downloads/private.key")
  certificate = file("~/Downloads/certificate.crt")

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "url-map" {
  name        = "url-map"
  default_service = google_compute_backend_service.wordpress-backend.id
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

