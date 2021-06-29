
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
    subnetwork = var.pub-sub-id
    access_config {}
  }
}

#This is a part of Compute Engine
#So here we also create instance template and managed instance group for WP

#Creating Instance-Template

resource "google_compute_instance_template" "wordpress-template" {
  name           = "wordpress-template"
  tags           = ["wordpress", "private"]
  machine_type   = "e2-micro"
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "wordpress-to-use-image"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.private-sub-id
  }

  service_account {
    email  = var.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = file("./modules/compute-engine/gcloud-startup-script")
}

#Creating instance-group group

resource "google_compute_region_instance_group_manager" "wordpress-ig" {
  name               = "wordpress-ig"
  base_instance_name = "wordpress"
  region             = var.region
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
    health_check      = google_compute_health_check.wp-heathcheck.id
    initial_delay_sec = 300

  }
}
#Creating autoscaler for IG

resource "google_compute_region_autoscaler" "wordpress-autoscaler" {
  name   = "wordpress-autoscaler"
  region = var.region
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
