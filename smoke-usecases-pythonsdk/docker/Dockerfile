ARG PYTHONSDK_VERSION=pythonsdk-release

FROM opnfv/xtesting:wallaby as pythonsdk-release

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

ARG ONAP_TESTS_TAG=master
ARG ONAPSDK_PYTHON_PATH=/src/onapsdk

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk add --no-cache python3 git && \
    apk add --no-cache --virtual .build-deps libffi-dev python3-dev \
        gcc openssl-dev linux-headers musl-dev && \
    pip3 install --upgrade pip && \
    pip3 install --ignore-installed --no-cache-dir \
        git+https://gerrit.onap.org/r/testsuite/pythonsdk-tests@$ONAP_TESTS_TAG && \
    mkdir -p $ONAPSDK_PYTHON_PATH/clamp && \
    wget -O $ONAPSDK_PYTHON_PATH/clamp/schema_details.json https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk/-/raw/develop/src/onapsdk/clamp/schema_details.json && \
    pip3 install markupsafe==2.0.1 && \
    apk del .build-deps

FROM pythonsdk-release as pythonsdk-develop
RUN pip3 install --no-cache-dir git+https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk@develop#onapsdk

FROM ${PYTHONSDK_VERSION} as final
COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
