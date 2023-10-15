FROM ubuntu:22.04

ARG TARGETARCH
ARG TARGETOS=linux

RUN set -e; \
    apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y \
      software-properties-common curl; \
    add-apt-repository --yes --update ppa:ansible/ansible; \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y \
    ca-certificates \
    python3 \
    python3-pip \
    python3-kubernetes \
    unzip \
    jq \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/

RUN set -e; \
  pip3 install --default-timeout=180 -r /tmp/requirements.txt --ignore-installed PyYAML; \
  rm /tmp/requirements.txt

# https://cloud.google.com/sdk/docs/release-notes
ARG GCLOUD_CLI_VERSION=450.0.0
RUN set -e; \
  curl -sSL -o /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_CLI_VERSION}-${TARGETOS}-$(uname -m).tar.gz; \
  tar -C /usr/local -xzf /tmp/google-cloud-sdk.tar.gz; \
  rm /tmp/google-cloud-sdk.tar.gz; \
  /usr/local/google-cloud-sdk/install.sh --quiet; \
  /usr/local/google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin --quiet


# https://github.com/hashicorp/terraform/releases
ARG TERRAFORM_VERSION=1.6.1
RUN set -e; \
  cd /tmp; \
  curl -Ss -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip; \
  unzip terraform.zip; \
  mv terraform /usr/local/bin/; \
  chmod +x /usr/local/bin/terraform; \
  rm terraform.zip

# https://github.com/kubernetes/kubernetes/releases
ARG KUBECTL_VERSION=1.28.2
RUN set -e; \
    cd /tmp; \
    curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl"; \
    mv kubectl /usr/local/bin/; \
    chmod +x /usr/local/bin/kubectl

# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.13.1
RUN set -e; \
  cd /tmp; \
  curl -Ss -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz; \
  tar xzf helm.tar.gz; \
  mv ${TARGETOS}-${TARGETARCH}/helm /usr/local/bin/; \
  chmod +x /usr/local/bin/helm; \
  rm -rf ${TARGETOS}-${TARGETARCH} helm.tar.gz

# https://github.com/coder/coder/releases
ARG CODER_VERSION=2.3.0
RUN  set -e; \
  cd /tmp; \
  curl -sSL -o coder.deb -C - https://github.com/coder/coder/releases/download/v${CODER_VERSION}/coder_${CODER_VERSION}_${TARGETOS}_${TARGETARCH}.deb; \
  dpkg --force-confdef --force-confold -i coder.deb; \
  rm -rf coder.deb

# https://github.com/binxio/gcp-get-secret
COPY --from=docker.io/binxio/gcp-get-secret:v0.4.6 /gcp-get-secret /usr/local/bin/

COPY automate /app/automate
COPY infrastructure /app/infrastructure
COPY *.sh /app/

ARG IMAGE_VERSION=latest
ARG IMAGE_NAME=coder-development-cluster

ENV IMAGE_NAME=${IMAGE_NAME}
ENV IMAGE_VERSION=${IMAGE_VERSION}
ENV PATH=${HOME}/.local/bin:${HOME}/bin:/usr/local/google-cloud-sdk/bin:${PATH}

WORKDIR /app

ENTRYPOINT ["/app/run_create.sh"]