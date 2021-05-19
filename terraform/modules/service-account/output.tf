#Adding output id for connecting module to other modules

output "service-account-email" {
  value = google_service_account.wp-service-account.email
}