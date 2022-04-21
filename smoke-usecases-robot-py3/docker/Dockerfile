FROM opnfv/xtesting:wallaby

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

ARG OPENSTACK_TAG=master
ARG OPNFV_TAG=master
ARG ONAP_TAG=jakarta
ARG PIP_TAG=21.2.4
ARG KUBERNETES_VERSION="v1.19.9"

ENV TAG all
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

COPY requirements.txt requirements.txt
RUN apk --no-cache add --update openssl && \
    apk --no-cache add --virtual .build-deps --update \
        python3-dev build-base linux-headers libffi-dev \
        openssl-dev libjpeg-turbo-dev && \
    git clone --depth 1 https://github.com/onap/cps.git -b $ONAP_TAG /cps  && \
    find /cps -mindepth 1 -name csit -prune -o -exec rm -rf {} + && \
    git clone --depth 1 https://github.com/onap/cps-cps-temporal.git -b $ONAP_TAG /cps-cps-temporal  && \
    find /cps-cps-temporal -mindepth 1 -name csit -prune -o -exec rm -rf {} + && \
    git clone --depth 1 https://github.com/onap/cps-ncmp-dmi-plugin.git -b $ONAP_TAG /cps-ncmp-dmi-plugin  && \
    find /cps-ncmp-dmi-plugin -mindepth 1 -name csit -prune -o -exec rm -rf {} + && \
    pip install --upgrade pip && \
    pip install --no-cache-dir \
    pip install \
        -chttps://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=$OPENSTACK_TAG \
        pip==$PIP_TAG && \
    pip install \
        -rrequirements.txt && \
    rm -r requirements.txt && \
    cd / && ln -s /var/opt/ONAP/robot/ /robot && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
COPY scripts/cmd.sh /
CMD ["/cmd.sh"]

