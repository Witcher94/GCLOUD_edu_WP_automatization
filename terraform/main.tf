
module "service-account" {
  source = "./modules/service-account"
}
module "network" {
  source     = "./modules/vpc-network/"
  depends_on = [module.service-account]
}
module "cloud-mysql" {
  source             = "./modules/cloud-mysql"
  master-connection  = module.network.master-connection
  replica-connection = module.network.replica-connection
  vpc-id             = module.network.vpc-network
  depends_on         = [module.network] #start after module "network"
}
module "wp-bucket" {
  source     = "./modules/wp-bucket"
  email      = module.service-account.service-account-email
  depends_on = [module.service-account]
}
module "compute-engine" {
  source         = "./modules/compute-engine"
  email          = module.service-account.service-account-email
  pub-sub-id     = module.network.public-sub-id
  private-sub-id = module.network.private-sub-id
  depends_on     = [module.network] #start after module "service account"
}
module "load-balancer" {
  source     = "./modules/load-balancer"
  ig-wp      = module.compute-engine.wp-ig
  heal       = module.compute-engine.wp-heath
  depends_on = [module.compute-engine]
}
module "dns" {
  source     = "./modules/DNS"
  wp-address = module.load-balancer.global-address
  depends_on = [module.load-balancer]
}