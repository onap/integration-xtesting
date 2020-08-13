FROM golang:1.13 AS build_aqua
WORKDIR /go/src/github.com/aquasecurity/
RUN git clone https://github.com/aquasecurity/kube-bench.git --depth 1
WORKDIR /go/src/github.com/aquasecurity/kube-bench
RUN GO111MODULE=on CGO_ENABLED=0 go install -a -ldflags "-w"

FROM golang:1.13 AS build_onap
WORKDIR /opt/onap
RUN git clone https://git.onap.org/integration --depth 1
WORKDIR /opt/onap/integration/test/security/sslendpoints
RUN CGO_ENABLED=0 go install -a -ldflags '-w -s -extldflags "-static"'

FROM opnfv/xtesting AS run

ARG KUBERNETES_VERSION="v1.15.2"
ARG HELM_VERSION="v2.14.1"
ARG ONAP_TAG=frankfurt
ARG ONAP_TESTS_TAG=frankfurt

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

COPY scripts/check_security_root.sh /check_security_root.sh
COPY scripts/root_pods_xfail.txt /root_pods_xfail.txt
COPY scripts/check_unlimitted_pods.sh /check_unlimitted_pods.sh
COPY scripts/check_cis_kubernetes.sh /check_cis_kubernetes.sh
COPY --from=build_aqua /go/bin/kube-bench /usr/local/bin/kube-bench
COPY --from=build_aqua /go/src/github.com/aquasecurity/kube-bench/cfg/ /cfg/
COPY --from=build_onap /go/bin/sslendpoints /usr/local/bin/sslendpoints

RUN set -x && \
    apk --no-cache add --update curl ca-certificates openssl procps util-linux \
        nmap nmap-scripts && \
    apk --no-cache add --virtual .build-deps --update \
        python3-dev linux-headers gcc  musl-dev && \
    chmod +x /usr/local/bin/kubectl && \
    git clone --depth 1 https://github.com/aquasecurity/kube-hunter.git /kube-hunter && \
    adduser kubectl -Du 2342 -h /config && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    wget -O /check_for_nonssl_endpoints.sh https://git.onap.org/integration/plain/test/security/check_for_nonssl_endpoints.sh?h=$ONAP_TAG &&\
    wget -O /check_for_jdwp.sh https://git.onap.org/integration/plain/test/security/check_for_jdwp.sh?h=$ONAP_TAG &&\
    wget -O /jdwp_xfail.txt https://git.onap.org/integration/plain/test/security/jdwp_xfail.txt?h=$ONAP_TAG &&\
    wget -O /nonssl_xfail.txt https://git.onap.org/integration/plain/test/security/nonssl_xfail.txt?h=$ONAP_TAG &&\
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/kube-bench && \
    chmod +x /usr/local/bin/sslendpoints && \
    chmod +x /check_*.sh && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
        git+https://gitlab.com/Orange-OpenSource/lfn/onap/integration/xtesting.git@$ONAP_TESTS_TAG#subdirectory=security && \
    cd /kube-hunter && pip3 install -r /kube-hunter/requirements.txt && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
