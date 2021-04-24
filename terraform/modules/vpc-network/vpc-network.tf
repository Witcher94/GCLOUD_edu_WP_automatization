resource "google_compute_network" "vpc_network" {
  name = "wordpress-network"
  mtu = 1500
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "public-subnetwork" {
  name = "bastion-sub"
  ip_cidr_range = "10.10.10.0/28"
  region = "europe-west3"
  network = google_compute_network.vpc_network.id
}
resource "google_compute_subnetwork" "private-subnetwork" {
  name = "wp-sub"
  ip_cidr_range = "10.10.10.16/28"
  region = "europe-west3"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_global_address" "private-ip-address" {
  name = "private-ip-address"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 28
  network = google_compute_subnetwork.private-subnetwork.ip_cidr_range
}
resource "google_compute_global_address" "replica-private-ip-address" {
  name = "private-ip-address"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 28
  network = google_compute_subnetwork.private-subnetwork.ip_cidr_range
}
resource "google_service_networking_connection" "master-private-vpc-db-connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private-ip-address.purpose]
}
resource "google_service_networking_connection" "replica-private-vpc-db-connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.replica-private-ip-address.purpose]
}

output "id" {
  value = google_compute_global_address.private-ip-address.address
}
output "master-connection" {
  value = google_service_networking_connection.master-private-vpc-db-connection
}
output "replica-connection" {
  value = google_service_networking_connection.replica-private-vpc-db-connection
}
output "vpc-network" {
  value = google_compute_network.vpc_network.id
}