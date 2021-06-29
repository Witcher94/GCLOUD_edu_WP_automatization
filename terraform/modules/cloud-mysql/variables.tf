#Importing input variables from output dependencies in VPC-network

variable "vpc-id" {
  type = string
}
variable "master-connection" {
  type = string
}
variable "replica-connection" {
  type = string
}
variable "region" {
  type    = string
  default = "europe-west3"
}
variable "db_version" {
  description = "Default Database version"
  type        = string
  default     = "MYSQL_5_6"
}
variable "username" {
  description = "Don't leave credentials in this section"
  type        = string
  default     = ""
}
variable "password" {
  description = "Don't leave credentials in this section"
  type        = string
  default     = ""
}
variable "database" {
  type    = string
  default = "wordpress"
}