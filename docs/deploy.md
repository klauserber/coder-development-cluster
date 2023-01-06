# Deployment

You need:

* docker on your machine

* A Google Cloud project, witch is prepared to deploy a coder development cluster. Look at the [bootstrap documentation](bootstrap.md) for more information.

* Credentials for the 3 service accounts (this files `google-coder-automation.json, google-coder-dns.json and google-coder-storage.json`). They are created during the bootstrap process.

## Configuration

Create a new directory for your project and put a `config/app_config.yml` file. Have a look at the [example config](app_config_template.yml) for more information.

Persist this configuration in a Google Cloud Secret:

```bash
./run_container.sh secrets_create.sh <GCLOUD_PROJECT> <CLUSTER_NAME>
```

Put the credential json files in the `config` directory.

## Cluster create

```bash
./run_container.sh run_create.sh <GCLOUD_PROJECT> <CLUSTER_NAME>
```

## Cluster destroy

```bash
./run_container.sh run_destroy.sh <GCLOUD_PROJECT> <CLUSTER_NAME>
```
