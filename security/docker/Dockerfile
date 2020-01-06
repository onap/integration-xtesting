FROM opnfv/xtesting

ARG ONAP_TAG=master
ARG PIP_TAG=19.3.1

COPY requirements.txt requirements.txt
RUN apk --no-cache add --virtual .build-deps --update \
        openssl-dev libjpeg-turbo-dev && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
CMD ["run_test -t all -r"]
