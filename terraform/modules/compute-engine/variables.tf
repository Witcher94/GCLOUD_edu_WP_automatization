
variable "email" {
  type = string
}
variable "pub-sub-id" {
  type = string
}
variable "private-sub-id" {
  type = string
}
variable "region" {
  type =  string
  default = "europe-west3"
}
variable "zone" {
  type = string
  default = "europe-west3-c"
}
variable "machine" {
  description = "Machine type used in module"
  type = string
  default = "e2-micro"
}
variable "tags" {
  type = list(string)
  default = ["bastion", "public"]
}
variable "image" {
  type = string
  default = "ubuntu-minimal-2004-lts"
}