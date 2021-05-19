#Output variables for other modules

output "id" {
  value = google_compute_global_address.private-ip-address.id
}
output "master-connection" {
  value = google_service_networking_connection.master-private-vpc-db-connection.id
}
output "replica-connection" {
  value = google_service_networking_connection.replica-private-vpc-db-connection.id
}
output "vpc-network" {
  value = google_compute_network.vpc-network.id
}
output "public-sub-id" {
  value = google_compute_subnetwork.public-subnetwork.id
}
output "private-sub-id" {
  value = google_compute_subnetwork.private-subnetwork.id
}
