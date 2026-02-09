FROM python:3.11-alpine

ARG ONAP_TESTS_TAG=master
ARG ONAPSDK_PYTHON_PATH=/src/onapsdk

RUN apk add --no-cache --virtual .build-deps \
        git \
        wget && \
    pip3 install --upgrade --no-cache-dir pip && \
    pip3 install --ignore-installed --no-cache-dir \
        git+https://gerrit.onap.org/r/testsuite/pythonsdk-tests@$ONAP_TESTS_TAG && \
    mkdir -p $ONAPSDK_PYTHON_PATH/clamp && \
    wget -O $ONAPSDK_PYTHON_PATH/clamp/schema_details.json https://git.onap.org/integration/python-onapsdk/plain/src/onapsdk/clamp/schema_details.json && \
    apk del .build-deps && \
    rm -rf /root/.cache /tmp/* /var/cache/apk/*

COPY docker/testcases.yaml /usr/local/lib/python3.11/site-packages/xtesting/ci/testcases.yaml
CMD ["run_tests", "-t", "all"]
