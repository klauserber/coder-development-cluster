# Bootstrap a google project

It is recommended to have a separate google project to run coder development clusters.

We need several conditions to be met before we can run a coder cluster.

# Automatic project configuration

You need:

  * docker on your machine
  * a google account

1. Create a new google cloud project and enable billing
2. Create a new directory and cd into it
3. Create a Script file called `run_container_bootstrap.sh` and paste the following code into it:

```bash
#!/usr/bin/env bash

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster
TAG=latest

echo "pull image ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG}"
docker pull ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} > /dev/null

COMMAND=run_bootstrap

docker run -it \
  -v $(pwd)/config:/app/config \
  --rm \
  --entrypoint=/app/${COMMAND}.sh \
  ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} ${@}
```

4. Create a directory called `config` and put a file called `app_config.yml` in it. The file should look like this:

```yaml
# This values will be used on google cloud project bootstrap and cluster creation

# Name of a existing Google Cloud project
# For bootstraping you must be the owner or editor of the project
project_id: spaces-example-com

# Domain name under which the clusters will be available
# Pattern: <cluster_name>.<domain_name>
domain_name: spaces.examle.com

# Name of the managed zone in Google Cloud DNS
# Will be used for creating the DNS records and for DNS challenges to generate certificates.
# Will be created on bootstraping if not exists
managed_zone: spaces-example.com

# Name of the bucket in Google Cloud Storage
# Will be used for storing the Terraform state, certificates cache, database and user directory backups.
# Will be created on bootstraping if not exists
bucket_name: coder-storage-spaces-example-com

# Google Cloud region for the storage bucket
region: europe-west3
```

5. Change the values in the `config/app_config.yml` file to match your project.

6. Run the `run_container_bootstrap.sh` script. It will create the required resources on google cloud.

```bash
./run_container_bootstrap.sh
```

7. After the script has finished you have the 3 json authentications keys (`google-coder-*.json`) in your config directory, **keep them safe**.

```bash
ls -l config/
total 40
-rw-r--r-- 1 coder coder 1706 Jan  4 09:08 app_config.yml
-rw------- 1 coder coder 2332 Jan  5 08:42 google-coder-automation.json
-rw------- 1 coder coder 2318 Jan  5 08:42 google-coder-dns.json
-rw------- 1 coder coder 2326 Jan  5 08:43 google-coder-storage.json
```

8. Point or delegate your domain to the nameservers of the created zone.

9. It could be a good idea to push the code to a git repository and add the `config` directory to your `.gitignore` file to prevent the keys from being pushed to a public repository.

## Manual project configuration

If you need a custom configuration you can do it manually.

There for it is good to know what the `run_container_bootstrap.sh` script does. Feel free to look into it to see the `gcloud` commands: [automate/roles/bootstrap_google_project/tasks/main.yml](../automate/roles/bootstrap_google_project/tasks/main.yml)

* Activate Google APIs:

  - compute.googleapis.com
  - container.googleapis.com
  - dns.googleapis.com
  - secretmanager.googleapis.com

* Create a service account `coder-automation` with the following roles:

  - roles/compute.networkAdmin
  - roles/compute.publicIpAdmin
  - roles/compute.securityAdmin
  - roles/container.admin
  - roles/container.clusterAdmin
  - roles/dns.admin
  - roles/secretmanager.admin
  - roles/storage.objectAdmin

* Create a service account `coder-dns` with the role `roles/dns.admin`

* Create a service account `coder-storage` with the role `roles/storage.objectAdmin`

* Grant the `coder-automation` service account editor access to the compute service account.

* Create a bucket for storing the Terraform state, certificates cache, database and user directory backups.

* Create a managed zone in Google Cloud DNS for the domain name.

---

Now you are ready to [deploy a coder development cluster](./deploy.md).
