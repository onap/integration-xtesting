FROM opnfv/xtesting:jerma

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

ARG OPENSTACK_TAG=master
ARG OPNFV_TAG=master
<<<<<<< HEAD   (450cdd Merge "[INFRA] Make helm3 runnable" into guilin)
ARG ONAP_TAG=guilin
=======
ARG ONAP_TAG=master
>>>>>>> CHANGE (ad7325 [INT] Use PIP 20.1 version)
ARG PIP_TAG=20.1
ARG KUBERNETES_VERSION="v1.15.11"

ENV TAG all

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

COPY requirements.txt requirements.txt
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
        -chttps://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=$OPENSTACK_TAG \
        pip==$PIP_TAG && \
    pip install \
        -chttps://git.opnfv.org/functest/plain/upper-constraints.txt?h=$OPNFV_TAG \
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
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.7/site-packages/xtesting/ci/testcases.yaml
COPY scripts/cmd.sh /
CMD ["/cmd.sh"]
