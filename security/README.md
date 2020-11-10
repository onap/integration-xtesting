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
- versions: check that Java and Python are available only in versions
  recommended by SECCOM. This test is long and run only in Weekly CI chains\
  (https://logs.onap.org/onap-integration/weekly).

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
nexus3.onap.org:10003/onap/xtesting-security:master
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
    tests of one CI run. It uses the regex (dai|week)ly-(.+?)-\[0-9]\* to find the
    version (e.g. daily-elalto-123456789).

The command becomes:

```
docker run -v <the kube config>:/root/.kube/config -v
<result directory>:/var/lib/xtesting/results
nexus3.onap.org:10003/onap/xtesting-security:master
/bin/bash -c "run_tests -r -t all"
```

Note that you can run only a subset of the tests and decide if you report the
results to the test BD or not.
The following commands are correct:

```
docker run -v <the kube config>:/root/.kube/config -v
<result directory>:/var/lib/xtesting/results
nexus3.onap.org:10003/onap/xtesting-security:master
/bin/bash -c "run_tests -t root_pods"
```

You can also run the docker in interactive mode, so you can run the tests from
inside the docker and directly modify the code of the test if you want.

```
docker run -it -v <the kube config>:/root/.kube/config -v
<result directory>:/var/lib/xtesting/results
nexus3.onap.org:10003/onap/xtesting-security:master bash
```

In this case you will get the bash prompt, you can run the test by typing in
the console

```
# run_tests -t unlimitted_pods
```

The code of the tests is in the docker. For python test, have a look at
/usr/lib/python3.8/site-packages, for security tests they are usually located
at /. See the Dockerfile for more information.



### Output

```
+-----------------------+------------+------------+-----------+
|       TEST CASE       |  PROJECT   |  DURATION  |  RESULT   |
+-----------------------+------------+------------+-----------+
|       root_pods       |  security  |   03:48    |   PASS    |
|    unlimitted_pods    |  security  |   00:37    |   FAIL    |
|     cis_kubernetes    |  security  |   00:01    |   PASS    |
|     kube_hunter       |  security  |   00:03    |   PASS    |
| http_public_endpoints |  security  |   00:01    |   PASS    |
|       jdpw_ports      |  security  |   05:39    |   PASS    |
+-----------------------+------------+------------+-----------+
```
