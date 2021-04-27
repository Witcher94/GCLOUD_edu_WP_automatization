#Creating VPC

resource "google_compute_network" "vpc-network" {
  name = "wordpress-network"
  mtu = 1500
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "public-subnetwork" {
  name = "bastion-sub"
  ip_cidr_range = "10.10.10.0/28"
  region = "europe-west3"
  network = google_compute_network.vpc-network.id
}
resource "google_compute_subnetwork" "private-subnetwork" {
  name = "wp-sub"
  ip_cidr_range = "10.10.10.16/28"
  region = "europe-west3"
  network = google_compute_network.vpc-network.id
}

#Creating connections for mysql DB

resource "google_compute_global_address" "private-ip-address" {
  name = "private-ip-address"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 28
  network = google_compute_subnetwork.private-subnetwork.id
}
resource "google_service_networking_connection" "master-private-vpc-db-connection" {
  network                 = google_compute_network.vpc-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = google_compute_global_address.private-ip-address.name
}
resource "google_service_networking_connection" "replica-private-vpc-db-connection" {
  network                 = google_compute_network.vpc-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = google_compute_global_address.private-ip-address.name
}

#Creating Firewall rules

resource "google_compute_firewall" "network-allow-ssh" {
  name    = "network-allow-ssh"
  network = google_compute_network.vpc-network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
resource "google_compute_firewall" "network-allow-openvpn" {
  name    = "network-allow-openvpn"
  network = google_compute_network.vpc-network.name

  allow {
    protocol = "udp"
    ports    = ["443"]
  }
  source_ranges = ["10.10.10.0/28"]
}
resource "google_compute_firewall" "network-allow-web" {
  name    = "network-allow-web"
  network = google_compute_network.vpc-network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["10.10.10.16/28"]
}
resource "google_compute_firewall" "network-allow-sql" {
  name    = "network-allow-mysql"
  network = google_compute_network.vpc-network.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_ranges = ["10.10.10.16/28"]
}

#Creating Cloud NAT/Router

resource "google_compute_router" "vpc-network-router" {
  name    = "vpc-network-router"
  region  = "europe-west3"
  network = google_compute_network.vpc-network.id
}

resource "google_compute_router_nat" "vpc-network-nat" {
  name                               = "vpc-network-nat"
  router                             = google_compute_router.vpc-network-router.name
  region                             = google_compute_router.vpc-network-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

#Output variables for other modules

output "id" {
  value = google_compute_global_address.private-ip-address.id
}
output "master-connection" {
  value = google_service_networking_connection.master-private-vpc-db-connection
}
output "replica-connection" {
  value = google_service_networking_connection.replica-private-vpc-db-connection
}
output "vpc-network" {
  value = google_compute_network.vpc-network.id
}
output "public-sub-id" {
  value = google_compute_subnetwork.public-subnetwork.id
}