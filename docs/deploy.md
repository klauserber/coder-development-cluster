# Deployment

You need:

* docker on your machine

* A Google Cloud project, witch is prepared to deploy a coder development cluster. Look at the [bootstrap documentation](bootstrap.md) for more information.

## Default configuration for all clusters

Create a new directory for your project and put a `config_default/app_config.yml` file in it. Have a look at the [example config](default_app_config_template.yml) for more information. May be this file is already there from the bootstrap process then you can extend it.

Put or check the credentials for the 3 service accounts (this files `google-coder-automation.json, google-coder-dns.json and google-coder-storage.json`) in the `config_default` directory. They are created during the bootstrap process.

## Configuration per cluster

Next we need a `config/app_config.yml` file. Have a look at the [example config](app_config_template.yml) for more information.

Persist this configuration in Google Cloud Secrets:

```bash
./run_container.sh secrets_create <GCLOUD_PROJECT> <CLUSTER_NAME>
```

## Cluster create

```bash
./run_container.sh run_create.sh <GCLOUD_PROJECT> <CLUSTER_NAME>
```

## Cluster destroy

```bash
./run_container.sh run_destroy.sh <GCLOUD_PROJECT> <CLUSTER_NAME>
```
