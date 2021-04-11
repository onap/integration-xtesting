FROM opnfv/xtesting

MAINTAINER Morgan Richomme <morgan.richomme@orange.com>

<<<<<<< HEAD   (5cf015 [HONOLULU] set honolulu version for honolulu xtesting docker)
ARG ONAP_TESTS_TAG=honolulu
=======
ARG ONAP_TESTS_TAG=master
>>>>>>> CHANGE (12e1aa [CLAMP] Fix path for schema_details.json)
ARG ONAPSDK_PYTHON_PATH=/src/onapsdk

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk add --no-cache python3 git && \
    apk add --no-cache --virtual .build-deps libffi-dev python3-dev \
        gcc openssl-dev linux-headers musl-dev && \
    pip3 install --upgrade pip && \
    pip3 install --editable \
        git+https://gerrit.onap.org/r/testsuite/pythonsdk-tests@$ONAP_TESTS_TAG#egg=onaptests && \
    mkdir -p $ONAPSDK_PYTHON_PATH/clamp && \
    wget -O $ONAPSDK_PYTHON_PATH/clamp/schema_details.json https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk/-/raw/develop/src/onapsdk/clamp/schema_details.json && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
