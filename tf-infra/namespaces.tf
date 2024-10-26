resource "kubernetes_namespace" "ns_dev" {
  for_each = var.envrionments
  metadata {
    name = each.key
  }
}