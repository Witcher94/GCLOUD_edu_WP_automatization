#Creating а service account for for further work

resource "google_service_account" "wp-service-account" {
  account_id = "wp-service"
}
resource "google_project_iam_member" "project" {
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.wp-service-account.email}"
}