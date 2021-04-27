#Creating а service account for for further work

resource "google_service_account" "wp-service-account" {
  account_id   = "wp-service"
}

#Adding some output id for connecting module to other modules

output "service-account-email" {
  value = google_service_account.wp-service-account.email
}