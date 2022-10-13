FROM ubuntu:22.04

ARG TARGETARCH=amd64
ARG TARGETOS=linux

RUN set -e; \
    apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y \
      software-properties-common; \
    add-apt-repository --yes --update ppa:ansible/ansible

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y \
    ca-certificates \
    ansible \
    python3 \
    python3-pip \
    python3-kubernetes \
    curl \
    unzip \
    jq \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/

RUN set -e; \
  pip3 install --default-timeout=180 -r /tmp/requirements.txt --ignore-installed PyYAML; \
  rm /tmp/requirements.txt


ARG TERRAFORM_VERSION=1.3.2
RUN set -e; \
  cd /tmp; \
  curl -Ss -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip; \
  unzip terraform.zip; \
  mv terraform /usr/local/bin/; \
  chmod +x /usr/local/bin/terraform; \
  rm terraform.zip

ARG KUBECTL_VERSION=1.24.6
RUN set -e; \
    cd /tmp; \
    curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl"; \
    mv kubectl /usr/local/bin/; \
    chmod +x /usr/local/bin/kubectl

ARG HELM_VERSION=3.10.1
RUN set -e; \
  cd /tmp; \
  curl -Ss -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz; \
  tar xzf helm.tar.gz; \
  mv ${TARGETOS}-${TARGETARCH}/helm /usr/local/bin/; \
  chmod +x /usr/local/bin/helm; \
  rm -rf ${TARGETOS}-${TARGETARCH} helm.tar.gz

ARG GCLOUD_CLI_VERSION=405.0.0
RUN set -e; \
  curl -sSL -o /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_CLI_VERSION}-${TARGETOS}-$(uname -m).tar.gz; \
  tar -C /usr/local -xzf /tmp/google-cloud-sdk.tar.gz; \
  rm /tmp/google-cloud-sdk.tar.gz; \
  /usr/local/google-cloud-sdk/install.sh --quiet; \
  /usr/local/google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin --quiet

ARG CODER_VERSION=0.9.9
RUN  set -e; \
  mkdir -p ~/.cache/coder; \
  curl -sSL -o ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb.incomplete -C - https://github.com/coder/coder/releases/download/v${CODER_VERSION}/coder_${CODER_VERSION}_${TARGETOS}_${TARGETARCH}.deb; \
  mv ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb.incomplete ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb; \
  dpkg --force-confdef --force-confold -i ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb; \
  rm -rf ~/.cache/coder

COPY automate /app/automate
COPY infrastructure /app/infrastructure
COPY run* /app/

ARG IMAGE_VERSION=latest
ARG IMAGE_NAME=coder-development-cluster

ENV IMAGE_NAME=${IMAGE_NAME}
ENV IMAGE_VERSION=${IMAGE_VERSION}
ENV PATH=${HOME}/.local/bin:${HOME}/bin:/usr/local/google-cloud-sdk/bin:${PATH}

WORKDIR /app

ENTRYPOINT ["/app/run.sh"]