FROM alpine:3.11

ARG RUNTIME_DEPS="libintl git ca-certificates curl jq py-pip python3 openssl bash"
ARG BUILD_DEPS="gnupg gettext gcc libffi-dev musl-dev openssl-dev python3-dev make"

ARG TERRAFORM_VERSION
ARG KUBERNETES_VERSION
ARG HELM_VERSION
ARG AZURE_CLI_VERSION

ENV TERRAFORM_VERSION "0.12.20"
ENV KUBERNETES_VERSION "1.16.4"
ENV HELM_VERSION "3.1.0"
ENV AZURE_CLI_VERSION "2.1.0"
ENV TF_PLUGIN_CACHE_DIR "/mods"

COPY ./main.tf /tmp/main.tf

RUN apk update --quiet && \
    apk upgrade --quiet && \
    apk add --quiet --no-cache ${RUNTIME_DEPS} && \
    apk add --quiet --no-cache --virtual build-dependencies ${BUILD_DEPS} && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_* && \
    curl -sL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    curl -OsL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz linux-amd64 && \
    pip3 --upgrade install pip && \
    pip3 --upgrade install azure-cli==${AZURE_CLI_VERSION} && \
    mkdir -p ${TF_PLUGIN_CACHE_DIR}/linux_amd64  && \
    cd /tmp && \
    terraform init && \ 
    apk del --quiet build-dependencies && \
    rm -rf /var/cache/apk/* /tmp/*

ENTRYPOINT []
