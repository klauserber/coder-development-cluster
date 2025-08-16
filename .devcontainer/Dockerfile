FROM isi006/coder-development-cluster

ARG TARGETARCH
ARG TARGETOS=linux

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y \
    wget \
    gnupg \
    unzip \
    zip \
    iputils-ping \
    sudo \
    git \
    vim \
    jq \
    ssh \
    pkg-config \
    dnsutils \
    iproute2 \
    rsync \
    pwgen \
    gettext-base \
    bash-completion \
    sipcalc \
    restic \
    tini \
    netcat-openbsd \
    zsh \
 && rm -rf /var/lib/apt/lists/*

# ##versions: https://hub.docker.com/_/docker/tags
COPY --from=docker:28.3.3-cli /usr/local/bin/docker /usr/local/bin/docker-compose /usr/local/bin/
RUN curl -s https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

# ##versions: https://hub.docker.com/r/docker/buildx-bin/tags
COPY --from=docker/buildx-bin:0.26.1 /buildx /usr/libexec/docker/cli-plugins/docker-buildx


# ##versions: https://github.com/derailed/k9s/releases
ARG K9S_VERSION=0.50.9
RUN set -e; \
  mkdir -p /tmp/k9s; \
  cd /tmp/k9s; \
  curl -LSs -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz; \
  tar xzf k9s.tar.gz; \
  mv k9s /usr/local/bin/; \
  cd /tmp; \
  rm -rf k9s


COPY bin/* /usr/local/bin/

RUN echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd && \
    usermod -aG root coder

# RUN mkdir -p /pyenv && chown coder:coder /pyenv

# source additional environment settings
COPY userenv /usr/local/etc/userenv
RUN echo "source /usr/local/etc/userenv" >> /etc/bash.bashrc && \
  echo "if [ -f /workspace/.env ]; then source /workspace/.env; fi" >> /etc/bash.bashrc

USER coder

# COPY requirements.txt /pyenv/
# RUN python3 -m venv /pyenv && \
#     . /pyenv/bin/activate && \
#     pip3 install -r /pyenv/requirements.txt -i https://mirrors.sustech.edu.cn/pypi/web/simple

# COPY --chown=coder:coder ansible-requirements.yaml /home/coder/.ansible/ansible-requirements.yaml
# RUN . /pyenv/bin/activate && ansible-galaxy collection install -r /home/coder/.ansible/ansible-requirements.yaml

# RUN helm plugin install https://github.com/databus23/helm-diff

# RUN curl -Ss -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en

RUN kubectl_plugins_install.sh

COPY --chown=coder:coder sshconfig /home/coder/.ssh/config
