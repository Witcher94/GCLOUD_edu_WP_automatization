variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "url_map" {
  description = "A reference (self_link) to the url_map resource to use."
  type        = string
}

variable "enable_ssl" {
  description = "Set to true to enable ssl. If set to 'true', you will also have to provide 'var.ssl_certificates'."
  type        = bool
  default     = false
}

variable "ssl_certificates" {
  description = "List of SSL cert self links. Required if 'enable_ssl' is 'true'."
  type        = list(string)
  default     = []
}

