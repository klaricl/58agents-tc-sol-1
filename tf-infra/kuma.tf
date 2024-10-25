resource "kubernetes_namespace" "ns_kuma" {
  metadata {
    name = "kuma"
  }
}

resource "kubernetes_service" "svc-kuma" {
  metadata {
    name = "svc-kuma"
    namespace = "kuma"
  }
  spec {
    selector = {
      app = "uptime-kuma"
    }
    port {
      port = 3001
      target_port = 3001
      name = "uptime-kuma"
      protocol = "TCP"
    }
  }
}


resource "kubernetes_ingress_v1" "ingress_kuma" {
  metadata {
    name = "kuma"
    namespace = "kuma"
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "svc-kuma"
              port {
                number = 3001
              }
            }
          }
          path = "/"
        }
      }
      host = "kuma.env"
    }
  }
}