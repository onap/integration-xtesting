# Local Development Setup with Docker

This README provides instructions for building and running the Docker image locally for development purposes.

## Building the Docker Image

### Quick Start

Build the image with the default configuration:

```bash
docker build -t onap-testsuite:dev .
```


### Custom Build Options

**Build with a specific ONAP tag:**

```bash
docker build --build-arg ONAP_TAG="jakarta" -t onap-testsuite:jakarta .
```

**Build with BuildKit for improved performance:**

```bash
DOCKER_BUILDKIT=1 docker build -t onap-testsuite:dev .
```


## Running the Development Container

### Interactive Development Mode

Start an interactive shell for development work:

```bash
docker run -it --rm \
  --name onap-dev \
  --volume $(pwd):/workspace \
  onap-testsuite:dev \
  /bin/bash
```

**For Windows users (PowerShell):**

```powershell
docker run -it --rm --name onap-dev --volume ${PWD}:/workspace onap-testsuite:dev /bin/bash
```


### Running Tests

Execute the test suite directly:

```bash
docker run --rm onap-testsuite:dev run_tests --help
```


### Development with Volume Mounts

Mount your local code for real-time development:

```bash
docker run -it --rm \
  --name onap-dev \
  --volume $(pwd):/workspace \
  --volume $(pwd)/local-tests:/app/tests \
  --workdir /workspace \
  onap-testsuite:dev \
  /bin/bash
```

For more information about ONAP testing, visit the [ONAP Testing Documentation](https://docs.onap.org/projects/onap-integration/en/latest/).
