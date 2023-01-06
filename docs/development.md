# Development

## Container image

There is a Dockerfile in the root of the repository to pack all automation code in a container image along with all needed tools to make it easy to run from a Docker host or a CD pipeline.

The `build.sh` Script will build the image and tag it with latest for quick local testing.

There is also a Github Workflow ([container_build.yml](../.github/workflows/container_build.yml)) to build, version and push the image to the Dockerhub Container Registry for AMD and ARM architectures (https://hub.docker.com/r/isi006/coder-development-cluster).

## Filesystem layout

* `.github/workflows` - Github Workflows, container build, run and destroy clusters
* `automate` - Ansible roles and playbooks
* `docs` - Documentation
* `infrastructure` - Terraform code
* `./*.sh` - Scripts to run and destroy clusters + helper scripts

## Constributing

Feel to send pull requests or open issues for any bugs or feature requests.
