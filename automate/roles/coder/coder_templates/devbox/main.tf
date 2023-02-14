
locals {
  workspace_name = lower(data.coder_workspace.me.name)
  workspace_owner = lower(data.coder_workspace.me.owner)
  k8s_username = "coder-${local.workspace_owner}-${local.workspace_name}"
  is_admin = (local.workspace_owner == "admin")
}

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
    name = "${var.workspaces_namespace}-${local.workspace_owner}-${local.workspace_name}"
    labels = {
      "user-namespace" = "1"
    }
  }
}

resource "kubernetes_role_binding" "namespace_admin" {
  count = local.is_admin ? 0 : 1
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
    kind      = "User"
    name      = local.k8s_username
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
}

resource "kubernetes_cluster_role_binding" "cluster_admin" {
  count = local.is_admin ? 1 : 0
  metadata {
    name      = "coder-${local.workspace_owner}-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = local.k8s_username
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "coder-${local.workspace_owner}-${local.workspace_name}"
    namespace = var.workspaces_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.homedir_disk_size
      }
    }
    storage_class_name = var.storage_class
  }
}

resource "kubernetes_job" "config" {
  metadata {
    name = "coder-${local.workspace_owner}-${local.workspace_name}"
    namespace = var.workspaces_namespace
  }
  spec {
    ttl_seconds_after_finished = 300
    template {
      metadata {}
      spec {
        service_account_name = "coder"
        container {
          name    = "user-config"
          image   = "isi006/k8s-user-config:latest"

          env {
            name  = "K8S_USER"
            value = local.k8s_username
          }
          env {
            name  = "K8S_CA_CERT"
            value = var.k8s_ca_cert
          }
          env {
            name  = "K8S_SERVER"
            value = var.k8s_server
          }
          env {
            name  = "K8S_CLUSTER_NAME"
            value = var.k8s_cluster_name
          }
          env {
            name  = "K8S_TARGET_NAMESPACE"
            value = var.workspaces_namespace
          }
          env {
            name  = "K8S_TARGET_SECRET"
            value = "${local.k8s_username}-kubeconfig"
          }
          env {
            name  = "K8S_DEFAULT_NAMESPACE"
            value = kubernetes_namespace.work-ns.metadata.0.name
          }
          env {
            name  = "CERT_EXPIRATION_SECONDS"
            value = var.cert_expiration_seconds
          }
          env {
            name  = "ADD_SUBJECT_CONFIG"
            value = "/O=coder-developer"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 2
  }
  wait_for_completion = true
}

resource "kubernetes_secret" "alertmanager_config_secret" {
  for_each = toset( var.smtp_enabled ? ["1"] : [])
  metadata {
    name = "alertmanager-config-secret"
    namespace = kubernetes_namespace.work-ns.metadata.0.name
  }
  data = {
    email-auth-password = var.smtp_password
  }
}

resource "kubernetes_manifest" "alertmanager_config" {
  for_each = toset( var.smtp_enabled ? ["1"] : [])
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1alpha1"
    "kind" = "AlertmanagerConfig"
    "metadata" = {
      "name" = "alertmanager-config"
      "namespace" = kubernetes_namespace.work-ns.metadata.0.name
    }
    "spec" = {
      "receivers" = [
        {
          "emailConfigs" = [
            {
              "authPassword" = {
                "key" = "email-auth-password"
                "name" = "alertmanager-config-secret"
              }
              "authUsername" = var.smtp_user
              "from" = var.smtp_from
              "sendResolved" = true
              "smarthost" = "${var.smtp_host}:${var.smtp_port}"
              "to" = data.coder_workspace.me.owner_email
            },
          ]
          "name" = "email"
        },
      ]
      "route" = {
        "groupBy" = [
          "alertname"
        ]
        "groupInterval" = "30s"
        "groupWait" = "5m"
        "receiver" = "email"
        "repeatInterval" = "1h"
      }
    }
  }
}


resource "kubernetes_stateful_set" "main" {
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
    service_name = "coder-${local.workspace_owner}-${local.workspace_name}"
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
            image   = "isi006/restic-kubernetes:2.0.0"
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
            chown -R 1000:1000 /home/coder;
            mkdir -p /home/coder/.kube;
            cp /kubeconfig/config /home/coder/.kube/config;
            chown 1000:1000 /home/coder/.kube/config;
            chmod 400 /home/coder/.kube/config;
            EOT
          ]
          volume_mount {
            mount_path = "/home/coder"
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
          }
        }
        dynamic "container" {
          for_each = toset( var.docker_service ? ["1"] : [])
          content {
            name    = "docker-dind"
            image   = "docker:23.0.1-dind"
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
            }
          }
        }
        dynamic "container" {
          for_each = toset( var.backup_service ? ["1"] : [])
          content {
            name    = "restic-backup"
            image   = "isi006/restic-kubernetes:2.0.0"
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
