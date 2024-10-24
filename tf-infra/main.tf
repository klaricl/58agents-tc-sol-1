resource "kubernetes_namespace" "ns_dev" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_namespace" "ns_qa" {
  metadata {
    name = "qa"
  }
}

resource "kubernetes_namespace" "ns_prod" {
  metadata {
    name = "prod"
  }
}