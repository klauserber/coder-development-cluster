FROM isi006/code-server-devbox:2.0.6

ARG TARGETARCH=amd64
ARG TARGETOS=linux
ARG IMAGE_VERSION=latest
ARG IMAGE_NAME=coder-development-cluster

ARG CODER_VERSION=0.9.9
RUN  set -e; \
  mkdir -p ~/.cache/coder; \
  curl -#fL -o ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb.incomplete -C - https://github.com/coder/coder/releases/download/v${CODER_VERSION}/coder_${CODER_VERSION}_${TARGETOS}_${TARGETARCH}.deb; \
  mv ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb.incomplete ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb; \
  sudo dpkg --force-confdef --force-confold -i ~/.cache/coder/coder_${CODER_VERSION}_${TARGETARCH}.deb; \
  rm -rf ~/.cache/coder

COPY --chown=coder automate /app/automate
COPY --chown=coder infrastructure /app/infrastructure
COPY --chown=coder run* /app/

ENV IMAGE_NAME=${IMAGE_NAME}
ENV IMAGE_VERSION=${IMAGE_VERSION}

WORKDIR /app

ENTRYPOINT ["/app/run.sh"]