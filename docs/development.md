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

## devcontainer

The repository includes a devcontainer configuration (https://containers.dev/) for Visual Studio Code or other compatible IDEs like the JetBrains products or Cursor. This allows you to develop inside a container with all the necessary tools and dependencies pre-installed.

To use the devcontainer, simply open the repository in Visual Studio Code and follow the prompts to reopen it in the container.

There is a Dockerfile and a Makefile to rebuild the devcontainer image. It is based on the main container image in the root of the repository.

## Contributing

Feel free to send pull requests or open issues for any bugs or feature requests.
