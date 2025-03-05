FROM opnfv/xtesting:leguer

ARG OPENSTACK_TAG=stable/newton
ARG OPNFV_TAG=stable/jerma
ARG ONAP_TAG=master
ARG PIP_TAG=20.1

ENV PYTHONPATH=$PYTHONPATH:/src/testing-utils/robotframework-onap/eteutils
ENV TAG=all
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

COPY requirements.txt requirements.txt
COPY upper-constraints.txt upper-constraints.txt
RUN git clone --depth 1 https://git.onap.org/testsuite -b $ONAP_TAG /var/opt/ONAP
RUN git clone --depth 1 https://git.onap.org/demo -b $ONAP_TAG /src/demo
RUN apk --no-cache add --update openssl chromium chromium-chromedriver && \
    apk --no-cache add --virtual .build-deps --update \
        python3-dev build-base linux-headers libffi-dev \
        openssl-dev libjpeg-turbo-dev curl rust
RUN pip3 install -U pip wheel
RUN pip3 install --no-cache-dir \
        -cupper-constraints.txt \
        git+https://git.onap.org/testsuite/heatbridge.git@$ONAP_TAG#egg=heatbridge\&subdirectory=heatbridge  \
        git+https://git.onap.org/testsuite/python-testing-utils.git@$ONAP_TAG#egg=robotframework-onap\&subdirectory=robotframework-onap \
        -rrequirements.txt
RUN mkdir -p /var/opt/ONAP/demo/heat && cp -Rf /src/demo/heat/vFW /var/opt/ONAP/demo/heat/ && \
    mkdir -p /demo/service_mapping && cp -Rf /src/demo/service_mapping /demo/ && \
    mkdir -p /var/opt/ONAP/demo/preload_data && cp -Rf /src/demo/preload_data /var/opt/ONAP/demo/ && \
    rm -r requirements.txt /var/opt/ONAP/.git /src/demo && \
    cd / && ln -s /var/opt/ONAP/robot/ /robot && \
    apk del .build-deps

COPY docker/testcases.yaml /usr/lib/python3.8/site-packages/xtesting/ci/testcases.yaml
COPY scripts/cmd.sh /
CMD ["/cmd.sh"]
