resource "kubernetes_namespace" "example" {
  metadata {
    name = "pipeline-test-fe"
  }
}