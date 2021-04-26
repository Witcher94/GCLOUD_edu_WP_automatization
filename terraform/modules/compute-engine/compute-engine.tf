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
  machine_type = "f1-micro"
  zone         = "europe-west3-c"
  tags         = ["bastion", "public"]
  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-focal-v20210223a"
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

resource "google_compute_instance_template" "wordpress-template-5" {
  name        = "wordpress-template"
  tags = ["wordpress", "private"]
  machine_type         = "f1-micro"
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

  metadata_startup_script = ""
}

data "template-file" "default" {
  template = "${file("./gcloud-startup-script.sh")}"


}