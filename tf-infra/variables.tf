variable "client_certificate" {
    type = string
}

variable "client_key" {
    type = string
}

variable "cluster_ca_certificate" {
    type = string
}

variable "environments" {
  type    = set(string)
  default = ["dev", "qa", "prod"]
}