#Importing module for output dependencies in VPC-network

input module "service-account" {
  source = "../service-account/"
}

#Creating WP-bucket

resource "google_storage_bucket" "wp-bucket" {
  name          = "wp-bucket1"
  location      = "Europe"
  force_destroy = true
  uniform_bucket_level_access = true
}

#Add permissions for correct work bucket

resource "google_storage_bucket_iam_member" "bucket-server-link" {
  bucket = google_storage_bucket.wp-bucket.name
  role = "roles/storage.admin"
  member = "serviceAccount:${module.service-account.service-account-email}"
}