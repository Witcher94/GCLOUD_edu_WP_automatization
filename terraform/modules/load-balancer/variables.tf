
variable "ig-wp" {
  type = string
}
variable "heal" {
  type = list(any)
}
variable "name" {
  type = string
  default = "http-redirect"
}
