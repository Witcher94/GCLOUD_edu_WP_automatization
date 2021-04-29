#Importing module for output dependencies in VPC-network

module "network" {
  source = "../vpc-network/"
}
#Creating Databases

resource "google_sql_database" "wordpress-database" {
  name     = "wordpress-database"
  instance = google_sql_database_instance.wordpress-db.name
}
resource "google_sql_database_instance" "wordpress-db" {
  name             = "wordpress-db-master"
  database_version = "MYSQL_5_6"
  region           = "europe-west-3"
  depends_on       = [module.network.master-connection]
  deletion_protection = "false"
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = module.network.vpc-network
    }
    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
  }
}
resource "google_sql_database_instance" "wordpress-db-replica" {
  name             = "wordpress-db-slave"
  database_version = "MYSQL_5_6"
  region           = "europe-west3"
  depends_on       = [module.network.replica-connection]
  deletion_protection  = "false"
  master_instance_name = google_sql_database_instance.wordpress-db.name
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = module.network.vpc-network
    }
  }
  replica_configuration {
      failover_target = true
  }
}
