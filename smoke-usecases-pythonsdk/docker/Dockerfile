FROM opnfv/xtesting

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

<<<<<<< HEAD   (450cdd Merge "[INFRA] Make helm3 runnable" into guilin)
ARG ONAP_TESTS_TAG=guilin
=======
ARG ONAP_TESTS_TAG=master
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
>>>>>>> CHANGE (4afbdf Fix xtesting docker build crypto issue)

RUN apk add --no-cache python3 git && \
    apk add --no-cache --virtual .build-deps libffi-dev python3-dev \
        gcc openssl-dev linux-headers musl-dev && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
        git+https://gerrit.onap.org/r/testsuite/pythonsdk-tests@$ONAP_TESTS_TAG && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
