variable "wp-address" {
  type = list
}

resource "google_dns_managed_zone" "sahay-pp" {
  name     = "pfaka.pp.ua"
  dns_name = "pfaka.pp.ua."
}

resource "google_dns_record_set" "sahay-pp" {
  managed_zone = google_dns_managed_zone.sahay-pp.name
  name         = "www.pfaka.pp.ua."
  type         = "A"
  rrdatas      = var.wp-address
  ttl          = 300
}
