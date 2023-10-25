---
name: Coder development cluster on GCP
description: Universal template for doing DevOps and development in the Google Cloud Platform.
tags: [bare]
---

# Coder development cluster on GCP

This template is a part of the Coder [development cluster project](https://github.com/klauserber/coder-development-cluster). It is a universal template for doing DevOps and development in the Google Cloud Platform.

## Links

### for users

- User interface: https://coder.{{ cluster_public_domain }}
- User account management: https://keycloak.{{ cluster_public_domain }}/realms/workshops-de/account

### for admins

- User administration: https://keycloak.{{ cluster_public_domain }}
- Grafana: https://grafana.{{ cluster_public_domain }}
- Prometheus: https://prometheus.{{ cluster_public_domain }}
- Alertmanager: https://alert.{{ cluster_public_domain }}
- Database administration: https://pgadmin.{{ cluster_public_domain }}

## The core features are

- Web based IDEs for developers (VSCode, see https://github.com/coder/code-server), no need to install anything on local machines
- Integration of local installations of different IDEs like VSCode, IntelliJ etc.
- Self registration via OIDC and Keycloak with email verification.
- Integrated file browser for the developer home directories to exchange data with the local machine.
- Fully functional development environment with plugin installations, docker builds, ports forwarding etc.
- Use es many images for different developer environments as you want.
- Out of the box Backup and Restore to and from Google Storage via continues WAL archiving for Postgres and Restic Backup of developer home directories.
- Works fine with cluster autoscaling.
- Automatic TLS certificate generation via cert-manager and Let's Encrypt.
- Single YAML file to configure everything.
- and more...

