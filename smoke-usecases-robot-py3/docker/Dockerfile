FROM opnfv/xtesting:wallaby

LABEL org.opencontainers.image.authors="Morgan Richomme <morgan.richomme@orange.com>"

ARG OPENSTACK_TAG=master
ARG OPNFV_TAG=master
ARG ONAP_TAG=master
ARG PIP_TAG=21.2.4
ARG KUBERNETES_VERSION="v1.32.0"
ARG HELM_VERSION="v3.17.0"

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
ADD https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 get_helm.sh

ENV TAG all
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

ARG PYTHON_UTILS_REPO=git.onap.org/testsuite/python-testing-utils.git
ARG PYTHON_UTILS_TAG=master

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

COPY requirements.txt requirements.txt
RUN apk --no-cache add --update openssl && \
    apk --no-cache add --virtual .build-deps --update \
        python3-dev build-base linux-headers libffi-dev \
        openssl-dev libjpeg-turbo-dev
RUN git clone --depth 1 https://github.com/onap/cps.git -b $ONAP_TAG /cps  && \
    find /cps -mindepth 1 -name csit -prune -o -exec rm -rf {} +
RUN git clone --depth 1 https://github.com/onap/cps-cps-temporal.git -b $ONAP_TAG /cps-cps-temporal  && \
    find /cps-cps-temporal -mindepth 1 -name csit -prune -o -exec rm -rf {} +
RUN git clone --depth 1 https://github.com/onap/cps-ncmp-dmi-plugin.git -b $ONAP_TAG /cps-ncmp-dmi-plugin  && \
    find /cps-ncmp-dmi-plugin -mindepth 1 -name csit -prune -o -exec rm -rf {} +
RUN git clone --depth 1 https://git.onap.org/testsuite -b $ONAP_TAG /var/opt/ONAP
RUN git clone --depth 1 https://git.onap.org/demo -b $ONAP_TAG /src/demo
# demo folder is required by the pnf_registrate smoke usecase
RUN mkdir -p /var/opt/ONAP/demo/heat && cp -Rf /src/demo/heat/vFW /var/opt/ONAP/demo/heat/ && \
    mkdir -p /var/opt/ONAP/demo/tosca && cp -Rf /src/demo/tosca/pNF /var/opt/ONAP/demo/tosca/ && \
    mkdir -p /demo/service_mapping && cp -Rf /src/demo/service_mapping /demo/ && \
    mkdir -p /var/opt/ONAP/demo/preload_data && cp -Rf /src/demo/preload_data /var/opt/ONAP/demo/ && \
    mkdir -p /app && cp /var/opt/ONAP/setup-hvves.sh /app/setup-hvves.sh && \
    chmod +x /app/setup-hvves.sh
RUN pip install --upgrade pip
RUN pip install \
        -r requirements.txt && \
    rm -r requirements.txt && \
    cd / && ln -s /var/opt/ONAP/robot/ /robot && \
    apk del .build-deps && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh --version $HELM_VERSION && \
    chmod +x /usr/local/bin/kubectl
RUN pip install --no-cache-dir git+https://$PYTHON_UTILS_REPO@$PYTHON_UTILS_TAG#egg=robotframework-onap\&subdirectory=robotframework-onap

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
COPY scripts/cmd.sh /
CMD ["/cmd.sh"]
