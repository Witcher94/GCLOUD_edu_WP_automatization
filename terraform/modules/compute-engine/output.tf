#output variables for other modules

output "wp-ig" {
  value = google_compute_region_instance_group_manager.wordpress-ig.instance_group
}
output "wp-heath" {
  value = [google_compute_health_check.wp-heathcheck.id]
}