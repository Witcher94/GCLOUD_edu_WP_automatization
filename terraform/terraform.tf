provider "google" {
  project     = "pfaka-education-25433"
  region      = "europe-west3"
}
module "service-account" {
  source = "./modules/service-account"
}
module "network" {
  source = "./modules/vpc-network/"
  depends_on = [module.service-account]
}
module "cloud-mysql" {
  source     = "./modules/cloud-mysql"
  depends_on = [module.network]  #start after module "network"
}
module "wp-bucket" {
  source = "./modules/wp-bucket"
  depends_on = [module.service-account]
}
module "compute-engine" {
  source = "./modules/compute-engine"
  depends_on = [module.service-account] #start after module "service account"
}
module "load-balancer" {
  source = "./modules/load-balancer"
  depends_on = [module.compute-engine]
}
