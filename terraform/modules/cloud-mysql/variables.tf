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