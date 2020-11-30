FROM opnfv/xtesting

ARG KUBERNETES_VERSION="v1.15.11"
ARG HELM_VERSION="v2.16.6"
ARG HELM3_VERSION="v3.3.4"
ARG ONAP_TESTS_TAG=master
ARG ONAP_TAG=master

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

COPY upper-constraints.txt .

RUN set -x && \
    apk --no-cache add --update curl ca-certificates && \
    apk --no-cache add --virtual .build-deps --update \
        gcc python3-dev musl-dev openssl-dev libffi-dev && \
    chmod +x /usr/local/bin/kubectl && \
    adduser kubectl -Du 2342 -h /config && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    wget https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm3 && \
    wget -O /check_for_ingress_and_nodeports.py https://git.onap.org/integration/plain/test/security/check_for_ingress_and_nodeports.py?h=$ONAP_TAG &&\
    chmod +x /usr/local/bin/helm && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r upper-constraints.txt && \
    pip3 install --no-cache-dir \
        git+https://git.onap.org/integration/xtesting.git@$ONAP_TESTS_TAG#subdirectory=infra-healthcheck && \
    pip3 install --no-cache-dir \
        git+https://git.onap.org/integration.git@$ONAP_TESTS_TAG#subdirectory=test/security/check_certificates && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
COPY docker/logging.ini /usr/lib/python3.8/site-packages/xtesting/ci/logging.ini
COPY docker/logging.debug.ini /usr/lib/python3.8/site-packages/xtesting/ci/logging.debug.ini
CMD ["run_tests", "-t", "all"]
