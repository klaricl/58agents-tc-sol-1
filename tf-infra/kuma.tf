resource "kubernetes_namespace" "ns_kuma" {
  metadata {
    name = "kuma"
  }
}