#Creating WP-bucket

resource "google_storage_bucket" "wp-bucket" {
  name                        = "wp-bucket14071994"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}

#Add permissions for correct work bucket

resource "google_storage_bucket_iam_member" "bucket-server-link" {
  bucket = google_storage_bucket.wp-bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${var.email}"
}