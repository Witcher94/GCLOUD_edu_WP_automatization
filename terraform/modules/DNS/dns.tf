
resource "google_dns_managed_zone" "pfaka-pp" {
  name     = "pfaka-pp"
  dns_name = "pfaka.pp.ua."
}

resource "google_dns_record_set" "pfaka-pp" {
  managed_zone = google_dns_managed_zone.pfaka-pp.name
  name         = "pfaka.pp.ua."
  type         = "A"
  rrdatas      = var.wp-address
  ttl          = 300
}
resource "dns_cname_record" "cname" {
  zone  = "pfaka.com."
  name  = "cname"
  cname = "www.pfaka.pp.ua"
  ttl   = 300
}
