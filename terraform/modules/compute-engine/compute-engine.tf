#Importing module for output dependencies in VPC-network

module "network" {
  source = "../vpc-network/"
}
module "service-account" {
  source = "../service-account"
}

#Creating instance for bastion server

resource "google_compute_instance" "bastion-edu" {
  name         = "bastion-edu"
  machine_type = "e2-micro"
  zone         = "europe-west3-c"
  tags         = ["bastion", "public"]
  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-lts"
    }
  }
  network_interface {
    subnetwork = module.network.public-sub-id
    access_config {}
  }
}

#This is a part of Compute Engine
#So here we also create instance template and managed instance group for WP

#Creating Instance-Template

resource "google_compute_instance_template" "wordpress-template" {
  name        = "wordpress-template"
  tags = ["wordpress", "private"]
  machine_type         = "e1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "wordpress-combo-image"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = module.network.id
  }

  service_account {
    email  = module.service-account.service-account-email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = "$file(\"gcloud-startup-script.sh\")"
}

#Creating instance-group group

resource "google_compute_region_instance_group_manager" "wordpress-ig" {
  name = "wordpress-ig"
  base_instance_name = "wordpress"
  region = "europe-west3"
  distribution_policy_zones = [
    "europe-west3-a",
    "europe-west3-b",
    "europe-west3-c"]

  version {
    instance_template = google_compute_instance_template.wordpress-template.id
  }
  named_port {
    name = "http"
    port = 80
  }
  auto_healing_policies {
    health_check = google_compute_health_check.wp-heathcheck.id
    initial_delay_sec = 300

  }
}
#Creating autoscaler for IG

resource "google_compute_region_autoscaler" "wordpress-autoscaler" {
  name   = "wordpress-autoscaler"
  region = "us-east1"
  target = google_compute_region_instance_group_manager.wordpress-ig.id
  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60
    cpu_utilization { target = 1 }
  }
}

#Adding heathcheck rules for IG

resource "google_compute_health_check" "wp-heathcheck" {
  name                = "wordpres-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 4

  tcp_health_check {
    port = "80"
  }
}

#output variables for other modules

output "wp-ig" {
  value = google_compute_region_instance_group_manager.wordpress-ig.instance_group
}
output "wp-heath" {
  value = [google_compute_health_check.wp-heathcheck.id]
}