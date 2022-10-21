
data "coder_workspace" "me" {}

resource "coder_agent" "devbox" {
  os             = "linux"
  arch           = "amd64"
  startup_script = <<EOF
  #!/bin/sh
  code-server --auth none --port 13337
  EOF
}

resource "kubernetes_namespace" "work-ns" {
  metadata {
    name = "${var.workspaces_namespace}-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  }
}

resource "kubernetes_service_account" "coder" {
  metadata {
    name      = "coder"
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
}

resource "kubernetes_role_binding" "role_binding" {
  metadata {
    name      = "coder-namespace-admin"
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "coder"
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
}

resource "kubernetes_stateful_set" "main" {
  count = data.coder_workspace.me.start_count
  metadata {
    name      = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
    namespace = var.workspaces_namespace
  }
  spec {
    replicas = 1
    service_name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
    selector {
      match_labels = {
        app = "coder"
        owner = "${data.coder_workspace.me.owner}"
        workspace = "${data.coder_workspace.me.name}"
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class

        resources {
          requests = {
            storage = var.homedir_disk_size
          }
        }
      }
    }

    template {
      metadata {
        labels = {
          app = "coder"
          owner = "${data.coder_workspace.me.owner}"
          workspace = "${data.coder_workspace.me.name}"
        }
      }
      spec {
        service_account_name = "coder"
        dynamic "volume" {
          for_each = toset( var.restic_storage_type == "gs" ? ["1"] : [])
          content {
            name = "google-credentials-secret"

            secret {
              secret_name = "google-credentials-secret"
            }
          }
        }
        init_container {
          name    = "init-chmod-data"
          image   = "busybox:latest"
          command = [ "sh" , "-c", "chown -R 1000:1000 /home/coder"]
          volume_mount {
            mount_path = "/home/coder"
            name       = "data"
          }
        }
        container {
          name    = "devbox"
          image   = var.devbox_image
          command = ["sh", "-c", var.devmode ? "sleep infinity" : coder_agent.devbox.init_script]
          security_context {
            run_as_user = "1000"
          }
          env {
            name  = "CODER_AGENT_TOKEN"
            value = coder_agent.devbox.token
          }
          env {
            name  = "DOCKER_HOST"
            value = "tcp://localhost:2375"
          }
          env {
            name  = "WORK_NAMESPACE"
            value = kubernetes_namespace.work-ns.metadata.0.name
          }
          port {
            container_port = 13337
          }
          resources {
            limits = {
              memory = "${var.devbox_mem_limit}M"
            }
            requests = {
              memory = "${var.devbox_mem_limit * 0.25}M"
              cpu = "250m"
            }
          }
          volume_mount {
            mount_path = "/home/coder"
            name       = "data"
          }
        }
        dynamic "container" {
          for_each = toset( var.docker_service ? ["1"] : [])
          content {
            name    = "docker-dind"
            image   = "docker:20.10-dind"
            args = [ "--mtu=1320" ]
            security_context {
              privileged = true
            }
            env {
              name  = "DOCKER_TLS_CERTDIR"
            }
            env {
              name  = "DOCKER_DRIVER"
              value = "overlay2"
            }
            resources {
              limits = {
                memory = "${var.docker_mem_limit}M"
              }
              requests = {
                memory = "${var.docker_mem_limit * 0.25}M"
                cpu = "250m"
              }
            }
            volume_mount {
              mount_path = "/home/coder"
              name       = "data"
            }
          }
        }
        dynamic "container" {
          for_each = toset( var.backup_service ? ["1"] : [])
          content {
            name    = "restic-backup"
            image   = "isi006/restic-kubernetes:1.1.1"
            env {
              name  = "AWS_ACCESS_KEY_ID"
              value = var.aws_access_key
            }
            env {
              name  = "AWS_SECRET_ACCESS_KEY"
              value = var.aws_secret_key
            }
            env {
              name  = "AWS_DEFAULT_REGION"
              value = var.aws_default_region
            }
            env {
              name  = "GOOGLE_APPLICATION_CREDENTIALS"
              value = "/etc/gcloud/google-cloud.json"
            }
            env {
              name  = "RESTIC_REPOSITORY"
              value = "${var.restic_repo_prefix}/coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
            }
            env {
              name  = "RESTIC_PASSWORD"
              value = "${var.restic_password_prefix}-${var.restic_password_suffix}"
            }
            env {
              name  = "BACKUP_CRON"
              value = var.backup_cron
            }
            env {
              name  = "RESTIC_FORGET_ARGS"
              value = var.restic_forget_args
            }
            env {
              name  = "RESTIC_HOST"
              value = "${var.workspaces_namespace}-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
            }
            resources {
              limits = {
                memory = "${var.backup_mem_limit}M"
              }
              requests = {
                memory = "${var.backup_mem_limit * 0.25}M"
                cpu = "250m"
              }
            }
            volume_mount {
              mount_path = "/data"
              name       = "data"
            }
            dynamic "volume_mount" {
              for_each = toset( var.restic_storage_type == "gs" ? ["1"] : [])
              content {
                mount_path = "/etc/gcloud"
                name       = "google-credentials-secret"
              }
            }
          }
        }
        dynamic "container" {
          for_each = toset( var.openvpn_service ? ["1"] : [])
          content {
            name    = "openvpn"
            image   = "isi006/openvpn-client:2.0.0"
            security_context {
              privileged = true
            }
            env {
              name  = "TZ"
              value = "Europe/Berlin"
            }
            resources {
              limits = {
                memory = "256M"
              }
              requests = {
                memory = "16M"
                cpu = "50m"
              }
            }
            volume_mount {
              mount_path = "/config"
              name       = "data"
              read_only  = true
            }
          }
        }
      }
    }
  }
}

resource "coder_app" "code-server" {
  agent_id = coder_agent.devbox.id
  name     = "code-server"
  url      = "http://localhost:13337/?folder=/home/coder"
  icon     = "/icon/code.svg"
}
