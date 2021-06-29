
resource "google_dns_managed_zone" "pfaka-pp" {
  name     = "pfaka-pp"
  dns_name = var.dns-name
}

resource "google_dns_record_set" "pfaka-pp" {
  managed_zone = google_dns_managed_zone.pfaka-pp.name
  name         = var .dns-name
  type         = "A"
  rrdatas      = var.wp-address
  ttl          = 300
}
resource "dns_cname_record" "cname" {
  zone  = var.dns-name
  name  = "www"
  cname = var.dns-name
  ttl   = 300
}
