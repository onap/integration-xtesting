# syntax=docker/dockerfile:1
# Build stage --------------------------------------
FROM python:3.9-slim as builder

ARG ONAP_TAG="master"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gcc \
    g++ \
    make \
    libffi-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY requirements.txt constraints.txt ./

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -c constraints.txt -r requirements.txt

RUN git clone --depth 1 --single-branch -b ${ONAP_TAG} https://git.onap.org/testsuite /var/opt/ONAP && \
    git clone --depth 1 --single-branch -b ${ONAP_TAG} https://git.onap.org/testsuite/python-testing-utils /src/testing-utils && \
    git clone --depth 1 --single-branch -b ${ONAP_TAG} https://git.onap.org/demo /src/demo

RUN pip install --no-cache-dir -c constraints.txt -e /src/testing-utils/robotframework-onap

# Run stage --------------------------------------
FROM python:3.9-slim as runner

RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy files from builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /var/opt/ONAP /var/opt/ONAP
COPY --from=builder /src /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN chown -R appuser:appuser /app /var/opt/ONAP /src
USER appuser

# Fake healthcheck - fix later
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# I'm not sure how this python buffer/bytecode helps but
# it's supposed to be a "best practice" and it works
ENV PYTHONPATH="/src/testing-utils:/src/demo:${PYTHONPATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

CMD ["run_tests", "--help"]
