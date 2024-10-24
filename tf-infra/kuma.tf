resource "kubernetes_namespace" "ns_prod" {
  metadata {
    name = "kuma"
  }
}