FROM golang:1.13 AS build_yq
WORKDIR /go/src/github.com/mikefarah/
RUN git clone https://github.com/mikefarah/yq.git --depth 1
WORKDIR /go/src/github.com/mikefarah/yq
RUN CGO_ENABLED=0 go install -a -ldflags '-w -s -extldflags "-static"'

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
ARG ONAP_TAG=master
ARG ONAP_TESTS_TAG=master

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

COPY scripts/check_security_root.sh /check_security_root.sh
COPY scripts/check_unlimitted_pods.sh /check_unlimitted_pods.sh
COPY scripts/check_cis_kubernetes.sh /check_cis_kubernetes.sh
COPY scripts/check_versions.sh /check_versions.sh
COPY --from=build_yq /go/bin/yq /usr/local/bin/yq
COPY --from=build_aqua /go/bin/kube-bench /usr/local/bin/kube-bench
COPY --from=build_aqua /go/src/github.com/aquasecurity/kube-bench/cfg/ /cfg/
COPY --from=build_onap /go/bin/sslendpoints /usr/local/bin/sslendpoints

RUN set -x && \
    apk --no-cache add --update curl ca-certificates openssl procps util-linux \
        nmap nmap-scripts jq && \
    apk --no-cache add --virtual .build-deps --update \
        python3-dev linux-headers gcc  musl-dev && \
    chmod +x /usr/local/bin/kubectl && \
    git clone --depth 1 https://github.com/aquasecurity/kube-hunter.git /kube-hunter && \
    mkdir /check_versions && \
    adduser kubectl -Du 2342 -h /config && \
    wget -O /check_for_nonssl_endpoints.sh https://git.onap.org/integration/plain/test/security/check_for_nonssl_endpoints.sh?h=$ONAP_TAG &&\
    wget -O /check_for_jdwp.sh https://git.onap.org/integration/plain/test/security/check_for_jdwp.sh?h=$ONAP_TAG &&\
    wget -O /jdwp_xfail.txt https://git.onap.org/integration/seccom/plain/waivers/jdwp_ports/jdwp_xfail.txt?h=$ONAP_TAG &&\
    wget -O /nonssl_xfail.txt https://git.onap.org/integration/seccom/plain/waivers/nonssl_endpoints/nonssl_xfail.txt?h=$ONAP_TAG &&\
    wget -O /root_pods_xfail.txt https://git.onap.org/integration/seccom/plain/waivers/root_pods/root_pods_xfail.txt?h=$ONAP_TAG &&\
    wget -O /unlimitted_pods_xfail.txt https://git.onap.org/integration/seccom/plain/waivers/unlimitted_pods/unlimitted_pods_xfail.txt?h=$ONAP_TAG &&\
    wget -O /check_versions/k8s_bin_versions_inspector.py https://git.onap.org/integration/plain/test/security/check_versions/src/k8s_bin_versions_inspector.py?h=$ONAP_TAG &&\
    wget -O /check_versions/requirements.txt https://git.onap.org/integration/plain/test/security/check_versions/env/requirements.txt?h=$ONAP_TAG &&\
    wget -O /check_versions/recommended_versions.yaml https://git.onap.org/integration/seccom/plain/recommended_versions.yaml?h=$ONAP_TAG &&\
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/kube-bench && \
    chmod +x /usr/local/bin/sslendpoints && \
    chmod +x /check_*.sh && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
        git+https://git.onap.org/integration/xtesting.git@$ONAP_TESTS_TAG#subdirectory=security && \
    cd /kube-hunter && pip3 install -r /kube-hunter/requirements.txt && \
    pip3 install -r /check_versions/requirements.txt && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
