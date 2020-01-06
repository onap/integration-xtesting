FROM opnfv/xtesting

ARG KUBERNETES_VERSION="v1.15.2"
ARG HELM_VERSION="v2.14.1"
ARG ONAP_TESTS_TAG=master

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

COPY scripts/check_onap_k8s.sh /check_onap_k8s.sh
COPY scripts/check_onap_helm.sh /check_onap_helm.sh

RUN set -x && \
    apk --no-cache add --update curl ca-certificates && \
    apk --no-cache add --virtual .build-deps --update \
        gcc python3-dev musl-dev && \
    chmod +x /usr/local/bin/kubectl && \
    adduser kubectl -Du 2342 -h /config && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    chmod +x /check_onap_*.sh && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
        git+https://gitlab.com/Orange-OpenSource/lfn/onap/integration/xtesting.git@$ONAP_TESTS_TAG#subdirectory=infra-healthcheck && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
