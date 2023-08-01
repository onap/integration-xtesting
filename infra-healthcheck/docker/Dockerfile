FROM python:3.11-alpine

ARG KUBERNETES_VERSION="v1.19.11"
ARG HELM_VERSION="v2.16.6"
ARG HELM3_VERSION="v3.3.4"
ARG ONAP_TESTS_TAG=master
ARG ONAP_TAG=master

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

# COPY upper-constraints.txt .
COPY . .

RUN set -x && \
    apk --no-cache add --update git curl ca-certificates && \
    apk --no-cache add --virtual .build-deps --update \
        gcc python3-dev musl-dev openssl-dev libffi-dev && \
    chmod +x /usr/local/bin/kubectl && \
    adduser kubectl -Du 2342 -h /config && \
    wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    wget https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm3 && \
    wget -O /check_for_ingress_and_nodeports.py https://git.onap.org/integration/plain/test/security/check_for_ingress_and_nodeports.py?h=$ONAP_TAG &&\
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm3 && \
    rm -rf /usr/local/lib/python3.11/site-packages/PyYAML* && \
    pip3 install --upgrade pip && \
    pip3 install --ignore-installed --no-cache-dir \
        -r requirements.txt -c upper-constraints.txt \
        -e . \
        git+https://git.onap.org/testsuite/pythonsdk-tests.git@$ONAP_TESTS_TAG \
        git+https://git.onap.org/integration.git@$ONAP_TAG#subdirectory=test/security/check_certificates && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/local/lib/python3.11/site-packages/xtesting/ci/testcases.yaml
COPY docker/logging.ini /usr/local/lib/python3.11/site-packages/xtesting/ci/logging.ini
COPY docker/logging.debug.ini /usr/local/lib/python3.11/site-packages/xtesting/ci/logging.debug.ini
CMD ["run_tests", "-t", "all"]
