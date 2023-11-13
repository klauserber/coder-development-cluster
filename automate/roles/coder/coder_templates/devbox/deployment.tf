resource "coder_metadata" "deployment_info" {
  count = data.coder_workspace.me.start_count
  resource_id = kubernetes_deployment.main.0.id
  item {
    key = "username"
    value = local.workspace_owner
  }
  item {
    key = "clustername"
    value = var.cluster_name
  }
  item {
    key = "working namespace"
    value = kubernetes_namespace.work-ns.metadata.0.name
  }
}

resource "kubernetes_deployment" "main" {
  depends_on = [
    kubernetes_job.config
  ]
  count = data.coder_workspace.me.start_count
  metadata {
    name      = "coder-${local.workspace_owner}-${local.workspace_name}"
    namespace = var.workspaces_namespace
  }
  spec {
    replicas = 1
    # service_name = "coder-${local.workspace_owner}-${local.workspace_name}"
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "coder"
        owner = "${local.workspace_owner}"
        workspace = "${local.workspace_name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "coder"
          owner = "${local.workspace_owner}"
          workspace = "${local.workspace_name}"
        }
      }
      spec {
        dynamic "volume" {
          for_each = toset( var.restic_storage_type == "gs" ? ["1"] : [])
          content {
            name = "google-credentials-secret"

            secret {
              secret_name = "google-credentials-secret"
            }
          }
        }
        dynamic "volume" {
          for_each = toset( var.desktop_setup ? ["1"] : [])
          content {
            name = "dshm"
            empty_dir {
              medium = "Memory"
            }

          }
        }
        volume {
          name = "k8s-config"
          secret {
            secret_name = "${local.k8s_username}-kubeconfig"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata.0.name
          }
        }
        dynamic "init_container" {
          for_each = toset( var.backup_service ? ["1"] : [])
          content {
            name    = "restic-restore"
            image   = "isi006/restic-kubernetes:2.2.1"
            env {
              name  = "RESTIC_RESTORE"
              value = "1"
            }
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
              value = "${var.restic_repo_prefix}/coder-${local.workspace_owner}-${local.workspace_name}"
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
              value = "${var.workspaces_namespace}-${local.workspace_owner}-${local.workspace_name}"
            }
            resources {
              limits = {
                memory = "${var.backup_mem_limit}M"
              }
              requests = {
                memory = "${var.backup_mem_limit * 0.25}M"
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
        init_container {
          name    = "init-chmod-data"
          image   = "busybox:latest"
          command = [ "sh" , "-c" ]
          args = [
            <<EOT
            mkdir -p /data/home;
            chown -R 1000:1000 /data/home;
            mkdir -p /data/home/.kube;
            cp /kubeconfig/config /data/home/.kube/config;
            chown 1000:1000 /data/home/.kube/config;
            chmod 400 /data/home/.kube/config;
            EOT
          ]
          volume_mount {
            mount_path = "/data"
            name       = "data"
          }
          volume_mount {
            mount_path = "/kubeconfig"
            name       = "k8s-config"
          }
        }
        container {
          name    = "devbox"
          image   = var.devbox_image
          command = ["sh", "-c", var.devmode ? "sleep infinity" : coder_agent.devbox.init_script]
          security_context {
            run_as_user = "1000"
            privileged  = true
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
            name  = "CLUSTER_NAME"
            value = var.cluster_name
          }
          env {
            name  = "CODER_USERNAME"
            value = local.k8s_username
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
            }
          }
          volume_mount {
            mount_path = "/home/coder"
            name       = "data"
            sub_path   = "home"
          }
          dynamic "volume_mount" {
            for_each = toset( var.desktop_setup ? ["1"] : [])
            content {
              mount_path = "/dev/shm"
              name       = "dshm"
            }
          }
        }
        dynamic "container" {
          for_each = toset( var.docker_service ? ["1"] : [])
          content {
            name    = "docker-dind"
            # https://hub.docker.com/_/docker/tags
            image   = "docker:24.0.6-dind"
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
              }
            }
            volume_mount {
              mount_path = "/home/coder"
              name       = "data"
              sub_path   = "home"
            }
            volume_mount {
              mount_path = "/var/lib/docker"
              name       = "data"
              sub_path   = "docker"
            }
          }
        }
        dynamic "container" {
          for_each = toset( var.backup_service ? ["1"] : [])
          content {
            name    = "restic-backup"
            image   = "isi006/restic-kubernetes:2.2.1"
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
              value = "${var.restic_repo_prefix}/coder-${local.workspace_owner}-${local.workspace_name}"
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
              value = "${var.workspaces_namespace}-${local.workspace_owner}-${local.workspace_name}"
            }
            resources {
              limits = {
                memory = "${var.backup_mem_limit}M"
              }
              requests = {
                memory = "${var.backup_mem_limit * 0.25}M"
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
      }
    }
  }
}
