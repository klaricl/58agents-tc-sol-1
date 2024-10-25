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

resource "kubernetes_stateful_set" "stateful_set_kuma" {
  metadata {
    name = "ing-kuma"
    namespace = "kuma"
  }
  spec {
    replicas = 1
    service_name = "svc-kuma"
    selector {
      match_labels = {
        app = "uptime-kuma"
      }
    }
    template  {
      metadata {
        labels = {
          app = "uptime-kuma"
        }
      }
      spec {
        container {
          image = "louislam/uptime-kuma"
          name = "uptime-kuma"
          env {
            name = "UPTIME_KUMA_PORT"
            value = "3001"
          }
          env {
            name = "PORT"
            value = "3001"
          }
          port {
            container_port = "3001"
            name = "uptime-kuma"
            protocol = "TCP"
          }
          volume_mount {
            name = "kuma-data"
            mount_path = "/app/data"
          }
        }
        volume_claim_template {
          metadata {
            name = "kuma-data"
          }
          spec {
            access_mode = {
              - "ReadWriteOnce"
            }
            volume_mode = "Filesystem"
            resources {
              requests = {
                storage = "1Gi"
              }
            }
          }
        }
      }
    }
  }
}