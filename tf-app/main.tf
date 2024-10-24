 data "terraform_remote_state" "tag" {
  count = var.env != "dev" ? 1 : 0
  backend = "local"

  config = {
    path = "../../../tfstate/${local.previous_stage}.${var.app_part_short}.tfstate"
  }
}

locals {
    image_tag = one(data.terraform_remote_state.tag[*].outputs.image_tag) != null ? one(data.terraform_remote_state.tag[*].outputs.image_tag) : var.image_tag
    previous_stage = var.env == "dev" ? "null" : var.env == "qa" ? "dev" : "qa"
}

output "previous_stage" {
  value = "${local.previous_stage}.${var.app_part_short}"
}

output "prevoius_tag" {
  value = one(data.terraform_remote_state.tag[*].outputs.image_tag)
}

resource "kubernetes_deployment" "deploy" {
  metadata {
    name = "${var.app_part_short}-app"
    namespace = var.env
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
          image = "lklaric/tc-${var.app_part_short}-app:${one(data.terraform_remote_state.tag[*].outputs.image_tag) != null ? one(data.terraform_remote_state.tag[*].outputs.image_tag) : var.image_tag}"
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
    namespace = var.env
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
    namespace = var.env
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
      host = "${var.app_part_short}.${var.env}"
    }
  }
}