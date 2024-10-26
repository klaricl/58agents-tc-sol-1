resource "kubernetes_namespace" "namespaces" {
  for_each = var.environments
  metadata {
    name = each.key
  }
}