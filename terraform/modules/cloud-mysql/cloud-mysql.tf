#Creating Databases

resource "google_sql_database" "wordpress-database" {
  name     = "wordpress-database"
  instance = google_sql_database_instance.wordpress-db.name
}
resource "google_sql_database_instance" "wordpress-db" {
  name                = "wordpress-master"
  database_version    = var.db_version
  region              = var.region
  depends_on          = [var.master-connection]
  deletion_protection = "false"
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc-id
    }
    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
  }
}
resource "google_sql_database_instance" "wordpress-db-replica" {
  name                 = "wordpress-slave"
  database_version     = var.db_version
  region               = var.region
  depends_on           = [var.replica-connection]
  deletion_protection  = "false"
  master_instance_name = google_sql_database_instance.wordpress-db.name
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc-id
    }
  }
  replica_configuration {
    failover_target = true
  }
}
resource "google_sql_user" "users" {
  name       = var.username
  instance   = google_sql_database_instance.wordpress-db.name
  host       = "%"
  password   = var.password
  depends_on = [google_sql_database_instance.wordpress-db]
}
resource "google_sql_database" "database" {
  name       = var.database
  instance   = google_sql_database_instance.wordpress-db
  depends_on = [google_sql_database_instance.wordpress-db]
}
