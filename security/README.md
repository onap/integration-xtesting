# Security

## Goal

This security docker includes the test suites dealing with security aspects
of an ONAP deployment.

It includes 6 tests:

- root_pods: check that pods are nor using root user or started as root
- unlimitted_pods: check that limits are set for pods
- cis_kubernetes: perform the k8s cis test suite (upstream src aquasecurity)
- http_public_endpoints: check that there is no public http endpoints exposed in
  ONAP cluster
- nonssl_endpoints: check that all public HTTP endpoints exposed in ONAP
  cluster use SSL tunnels
- jdpw_ports: check that there are no internal java ports
- kube_hunter: security suite to search k8s vulnerabilities (upstream src
  aquasecurity)

## Usage

### Configuration

Mandatory:

- The kubernetes configuration: usually hosted on the.kube/config of your
  jumphost. It corresponds the kubernetes credentials and are needed to perform
  the different operations. This file shall be copied in /root/.kube/config in
  the docker.

Optional:

- The local result directory path: to store the results in your local
  environement. It shall corresponds to the internal result docker path
  /var/lib/xtesting/results

### Command

You can run this docker by typing:

```
docker run -v <the kube config>:/root/.kube/config -v
<result directory>:/var/lib/xtesting/results
registry.gitlab.com/orange-opensource/lfn/onap/integration/xtesting/security:latest
```

Options:

- \-r: by default the reporting to the Database is not enabled. You need to
  specify the -r option in the command line. Please note that in this case, you
  must precise some env variables.

environment variables:

- Mandatory (if you want to report the results in the database):
  - TEST_DB_URL: the url of the target Database with the env variable .
  - NODE_NAME: the name of your test environement. It must be declared in the
    test database (e.g. windriver-SB00)
- Optionnal
  - INSTALLER_TYPE: precise how your ONAP has been installed (e.g. kubespray-oom,
    rke-oom)
  - BUILD_TAG: a unique tag of your CI system. It can be usefull to get all the
    tests of one CI run. It uses the regex (dai|week)ly-(.+?)-[0-9]\* to find the
    version (e.g. daily-elalto-123456789).

The command becomes:

```
docker run -v <the kube config>:/root/.kube/config -v
<result directory>:/var/lib/xtesting/results registry.gitlab.com/orange-opensour
ce/lfn/onap/integration/xtesting/security:latest /bin/bash -c "run_tests -r -t all
```

### Output

```
+-----------------------+------------+------------+------------+-----------+
|       TEST CASE       |  PROJECT   |    TIER    |  DURATION  |  RESULT   |
+-----------------------+------------+------------+------------+-----------+
|       root_pods       |  security  |  security  |   03:48    |   FAIL    |
|    unlimitted_pods    |  security  |  security  |   00:37    |   FAIL    |
|     cis_kubernetes    |  security  |  security  |   00:01    |   FAIL    |
| http_public_endpoints |  security  |  security  |   00:01    |   FAIL    |
|       jdpw_ports      |  security  |  security  |   05:39    |   FAIL    |
+-----------------------+------------+------------+------------+-----------+
```
