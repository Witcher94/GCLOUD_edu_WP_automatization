
output "global-address" {
  value = [google_compute_global_address.wordpress-front.address]
}