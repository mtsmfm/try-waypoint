FROM ruby:2.7.2

LABEL org.opencontainers.image.source https://github.com/mtsmfm/try-waypoint

ARG USERNAME=app
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV SHELL=/bin/bash

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && apt-get update \
  && apt-get install -y software-properties-common gnupg \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-get update \
  && apt-get install -y sudo postgresql-client nodejs waypoint google-cloud-sdk \
  && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

ENV BUNDLE_PATH=/app/vendor/bundle
RUN mkdir -p /app /original /persisted $BUNDLE_PATH
RUN chown -R $USERNAME /app /original /persisted $BUNDLE_PATH

USER $USERNAME

WORKDIR /app
