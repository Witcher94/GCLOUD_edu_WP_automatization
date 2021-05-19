terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<4.0,>= 2.12"
      project     = "pfaka-education-25433"
      region      = "europe-west3"
    }
  }
}