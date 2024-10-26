resource "kubernetes_deployment" "deploy" {
  for_each = var.environments
  metadata {
    name = "db"
    namespace = each.key
    labels = {
      app = "db"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "db"
      }
    }
    template {
      metadata {
        labels = {
          app = "db"
        }
      }
      spec {
        container {
          image = "postgres"
          name = "db"
          port {
            container_port = 5432
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "postgres"
          }
          volume_mount {
            name = "script"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }
        volume {
          name = "script"
          config_map {
            name = "db-user-init"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc_db" {
  for_each = var.environments
  metadata {
    name = "svc-db"
    namespace = each.key
  }
  spec {
    selector = {
      app = "db"
    }
    port {
      port = 5432
      target_port = 5432
      name = "postgres"
      protocol = "TCP"
    }
  }
}

resource "kubernetes_config_map" "db_user_init" {
  for_each = var.environments
  metadata {
    name = "db-user-init"
    namespace = each.key
  }
  data = {
    user-init.sh = <<EOT
        #!/bin/bash
        set -e
    
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        	CREATE USER vrbaadm;
        	CREATE DATABASE vrba;
        	GRANT ALL PRIVILEGES ON DATABASE vrba TO vrbaadm;
          \c vrba
          CREATE TABLE IF NOT EXISTS messages (
            name varchar(45) NOT NULL,
            email varchar(50) NOT NULL,
            msg varchar(50) NOT NULL,
            id SERIAL PRIMARY KEY
          )
        EOSQL
    EOT
  }
}