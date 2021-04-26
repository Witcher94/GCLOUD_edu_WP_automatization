provider "google" {
  credentials = file("service_account.json")
  project     = ""
  region      = "europe-west3"
  zone        = "europe-west3-c"

}
module "network" {
  source = "./modules/vpc-network/"
}
module "service-account" {
  source = "./modules/service-account"
  depends_on = [module.network]
}
module "cloud-mysql" {
  source     = "./modules/cloud-mysql"
  network    = module.network.id #input value from network module for private ip
  depends_on = [module.network]  #start after module "network"
}
module "wp-bucket" {
  source = "./modules/wp-bucket"
  depends_on = [module.service-account]
}
module "compute-engine" {
  source = "./modules/compute-engine"
  network    = module.network.id
  depends_on = [module.service-account] #start after module "service account"
}
