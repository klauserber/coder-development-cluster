# Integration

## Github

If you want to deploy or destroy coder development clusters with Github Actions, you can use the workflows from this project as a starting point:

* Deploy a cluster: [run.yml](../.github/workflows/run.yml)
* Destroy a cluster: [destroy.yml](../.github/workflows/destroy.yml)

Theses workflows are using github secrets in environments (https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment). You need to add 4 Secrets per environment:

* `GCLOUD_PROJECT` - The ID of the GCP project
* `GOOGLE_CODER_AUTOMATION` - The service account key for the automation service account
* `GOOGLE_CODER_DNS` - The service account key for the DNS service account
* `GOOGLE_CODER_STORAGE` - The service account key for the storage service account
