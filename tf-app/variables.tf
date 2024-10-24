variable "client_certificate" {
    type = string
}

variable "client_key" {
    type = string
}

variable "cluster_ca_certificate" {
    type = string
}

variable "image_tag" {
    type = string
    default = null
}

variable "app_part_short" {
    type = string
}

variable "env" {
    type = string
    default = "dev"
}
