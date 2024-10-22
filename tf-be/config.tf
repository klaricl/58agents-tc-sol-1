terraform {
}

provider "kubernetes" {
  host = "https://192.168.49.2:8443"

  #client_certificate     = file("/home/luka/workspace/58_agents_tech_challenge/k8s_creds/tf.crt")
  client_certificate     = base64decode(var.client_certificate)
  client_key             = file(var.client_key)
  cluster_ca_certificate = file(var.cluster_ca_certificate)
}