resource "kubernetes_namespace" "namespaces" {
  for_each = var.envrionments
  metadata {
    name = each.key
  }
}