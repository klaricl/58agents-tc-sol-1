terraform {
  backend "local" {}
}

provider "kubernetes" {
  host = "https://192.168.49.2:8443"
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}