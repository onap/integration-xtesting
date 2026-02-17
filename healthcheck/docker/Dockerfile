FROM python:3.10-slim

ARG ONAP_TAG=master

ENV PYTHONPATH=$PYTHONPATH:/src/testing-utils/robotframework-onap/eteutils
ENV TAG=all

# Install git for cloning repos
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt

# Clone ONAP testsuite and demo repos
RUN git clone --depth 1 https://git.onap.org/testsuite -b $ONAP_TAG /var/opt/ONAP && \
    git clone --depth 1 https://git.onap.org/demo -b $ONAP_TAG /src/demo

# Install build dependencies and Python packages
# Use testsuite's requirements.txt to stay in sync with upstream versions
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev && \
    pip3 install --no-cache-dir --upgrade pip wheel && \
    pip3 install --no-cache-dir \
        -r /var/opt/ONAP/requirements.txt \
        -r requirements.txt && \
    apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup ONAP test data directories
RUN mkdir -p /var/opt/ONAP/demo/heat && cp -Rf /src/demo/heat/vFW /var/opt/ONAP/demo/heat/ && \
    mkdir -p /demo/service_mapping && cp -Rf /src/demo/service_mapping /demo/ && \
    mkdir -p /var/opt/ONAP/demo/preload_data && cp -Rf /src/demo/preload_data /var/opt/ONAP/demo/ && \
    rm -rf requirements.txt /var/opt/ONAP/.git /src/demo && \
    cd / && ln -s /var/opt/ONAP/robot/ /robot

COPY docker/testcases.yaml /usr/local/lib/python3.10/site-packages/xtesting/ci/testcases.yaml
COPY scripts/cmd.sh /
CMD ["/cmd.sh"]
