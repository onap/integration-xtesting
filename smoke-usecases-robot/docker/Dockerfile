FROM opnfv/xtesting:jerma

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

ARG OPENSTACK_TAG=yoga
ARG OPNFV_TAG=stable/jerma
ARG ONAP_TAG=master
ARG PIP_TAG=20.1
ARG KUBERNETES_VERSION="v1.19.9"
ARG HELM_VERSION="v3.3.4"

ENV TAG all
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
ADD https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 get_helm.sh

COPY requirements.txt requirements.txt
COPY upper-constraints.txt upper-constraints.txt
RUN apk --no-cache add --update openssl chromium chromium-chromedriver && \
    apk --no-cache add --virtual .build-deps --update \
        python3-dev build-base linux-headers libffi-dev \
        openssl-dev libjpeg-turbo-dev && \
    chmod +x /usr/local/bin/kubectl && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
    git+https://git.onap.org/testsuite/heatbridge.git@$ONAP_TAG#egg=heatbridge\&subdirectory=heatbridge  \
    git+https://git.onap.org/testsuite/python-testing-utils.git@$ONAP_TAG#egg=robotframework-onap\&subdirectory=robotframework-onap && \
    git clone --depth 1 https://git.onap.org/testsuite -b $ONAP_TAG /var/opt/ONAP && \
    git clone --depth 1 https://git.onap.org/demo -b $ONAP_TAG /src/demo && \
    pip install \
        -chttps://releases.openstack.org/constraints/upper/$OPENSTACK_TAG \
        pip==$PIP_TAG && \
    pip install \
        -chttps://git.opnfv.org/functest/plain/upper-constraints.txt?h=$OPNFV_TAG \
        -cupper-constraints.txt \
        -rrequirements.txt && \
    mkdir -p /var/opt/ONAP/demo/heat && cp -Rf /src/demo/heat/vFW /var/opt/ONAP/demo/heat/ && \
    mkdir -p /var/opt/ONAP/demo/tosca && cp -Rf /src/demo/tosca/pNF /var/opt/ONAP/demo/tosca/ && \
    mkdir -p /demo/service_mapping && cp -Rf /src/demo/service_mapping /demo/ && \
    mkdir -p /var/opt/ONAP/demo/preload_data && cp -Rf /src/demo/preload_data /var/opt/ONAP/demo/ && \
    mkdir -p /app && cp /var/opt/ONAP/setup-hvves.sh /app/setup-hvves.sh && \
    chmod +x /app/setup-hvves.sh && \
    ln -s /usr/lib/python3.7/site-packages/vcpeutils /usr/lib/python3.7/site-packages/SoUtils && \
    ln -s /usr/lib/python3.7/site-packages/heatbridge /usr/lib/python3.7/site-packages/HeatBridge && \
    rm -r requirements.txt /var/opt/ONAP/.git /src/demo && \
    cd / && ln -s /var/opt/ONAP/robot/ /robot && \
    apk del .build-deps && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh --version $HELM_VERSION

COPY docker/testcases.yaml /usr/lib/python3.7/site-packages/xtesting/ci/testcases.yaml
COPY scripts/cmd.sh /
CMD ["/cmd.sh"]
