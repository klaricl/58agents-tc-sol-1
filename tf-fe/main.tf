resource "kubernetes_namespace" "example" {
  metadata {
    name = "pipeline-test-fe"
  }
}

resource "kubernetes_deployment" "fe_deploy" {
  metadata {
    name = "fe-app"
    labels = {
      app = "fe-app"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "fe-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "fe-app"
        }
      }
      spec {
        container {
          image = "lklaric/tc-fe-app:${var.image_tag}"
          name = "fe-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc-fe-app" {
  metadata {
    name = "svc-fe-app"
  }
  spec {
    selector = {
      app = "fe-app"
    }
    port {
      port = 80
      target_port = 80
      name = "http"
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "ingress_fe_app" {
  metadata {
      name = "ingress-fe-app"
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "svc-fe-app"
              port {
                #name = "http"
                number = 80
              }
            }
          }
          path = "/"
        }
      }
      host = "fe.127.0.0.1.nip.io"
    }
  }
}