FROM opnfv/xtesting

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

ARG ONAP_TESTS_TAG=master

RUN apk add --no-cache python3 git && \
    apk add --no-cache --virtual .build-deps libffi-dev python3-dev \
        gcc openssl-dev linux-headers musl-dev && \
    pip3 install --upgrade pip && \
    pip3 install --editable \
        git+https://gerrit.onap.org/r/testsuite/pythonsdk-tests@$ONAP_TESTS_TAG#egg=onaptests && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
