resource "kubernetes_deployment" "deploy" {
  metadata {
    name = "${var.app_part_short}-app"
    labels = {
      app = "${var.app_part_short}-app"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.app_part_short}-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.app_part_short}-app"
        }
      }
      spec {
        container {
          image = "lklaric/tc-${var.app_part_short}-app:${var.image_tag}"
          name = "${var.app_part_short}-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc-app" {
  metadata {
    name = "svc-${var.app_part_short}-app"
  }
  spec {
    selector = {
      app = "${var.app_part_short}-app"
    }
    port {
      port = 80
      target_port = 80
      name = "http"
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "ingress_app" {
  metadata {
      name = "ingress-${var.app_part_short}-app"
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "svc-${var.app_part_short}-app"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
      host = "${var.app_part_short}.example"
    }
  }
}