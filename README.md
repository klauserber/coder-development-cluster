# coder-development-cluster

This piece of infrastructure code lets you create a kubernetes cluster with all components needed to run the coder platform on the Google Cloud Platform. Follow this link for more informations about the coder platform:

  https://coder.com

The core features are:

- Web based IDEs for developers (VSCode, see https://github.com/coder/code-server), no need to install anything on local machines
- Integration of local installations of different IDEs like VSCode, IntelliJ etc.
- Self registration via OIDC and Keycloak with email verification.
- Fully functional development environment with plugin installations, docker builds, ports forwarding etc.
- Use es many images for different developer environments as you want.
- Out of the box Backup and Restore to and from Google Storage via continues WAL archiving for Postgres and Restic Backup of developer home directories.
- Works fine with cluster autoscaling.
- Automatic TLS certificate generation via cert-manager and Let's Encrypt.
- Single YAML file to configure everything.
- and more...

## Dokumentation

Artchitecture: [docs/Architecture.md](docs/Architecture.md)



