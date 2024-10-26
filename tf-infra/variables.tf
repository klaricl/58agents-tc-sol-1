variable "client_certificate" {
    type = string
}

variable "client_key" {
    type = string
}

variable "cluster_ca_certificate" {
    type = string
}

variable "enviroments" {
  type    = set(string)
  default = ["dev", "qa", "prod"]
}