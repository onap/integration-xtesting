# infra-healthcheck

## Goal

This infra-healthcheck docker includes the test suites checking kubernetes and
healm charts of an ONAP deployment.

It includes 2 tests:

- onap-k8s: list pods, deployments, events, cm, ... For any faulty pod, it
  collects the logs and the describe. The success criteria is 100% of the pods
  are up and running
- onap-helm: list the helm charts. The success criteria is all the helm charts
  are completed.
- nodeport_ingress: check that we have a 1:1 correspondance between nodeports
  and ingress (run only when the env variable DEPLOY_SCENARIO includes ingress)

Please note that you will find another test (onap-k8s-teardown) in CI. It is exactly
the same than onap-k8s (status of the onap cluster) executed at the end of the
CI, after all the other tests. It allows to collect the logs of the components.

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
nexus3.onap.org:10003/onap/xtesting-infra-healthcheck:latest
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
- Optional:
  - INSTALLER_TYPE: precise how your ONAP has been installed (e.g. kubespray-oom,
    rke-oom)
  - BUILD_TAG: a unique tag of your CI system. It can be usefull to get all the
    tests of one CI run. It uses the regex (dai|week)ly-(.+?)-\[0-9]\* to find the
    version (e.g. daily-elalto-123456789).
  - DEPLOY_SCENARIO: your scenario deployment. ingress test run only if the
    scenario includes 'ingress'
  - ONAP_RELEASE: the name of the onap release in Helm. Default is "onap".
  - ONAP_HELM_LOG_PATH: the path where to retrieve specific logs that helm
    deploy has captured. you should add a volume if you want to retrieve them:
    `-v <the user home dir>/.helm/plugins/deploy/cache/onap/logs:/onap_helm_logs`.
    `/onap_helm_logs` is the default value.

The command becomes:

```
docker run -v <the kube config>:/root/.kube/config -v
-v <the user home dir>/.helm/plugins/deploy/cache/onap/logs:/onap_helm_logs
<result directory>:/var/lib/xtesting/results
nexus3.onap.org:10003/onap/xtesting-infra-healthcheck:latest:latest
/bin/bash -c "run_tests -r -t all"
```

### Output

```
+------------------+-------------+-------------------+----------+--------+
| TEST CASE        | PROJECT     | TIER              | DURATION | RESULT |
+------------------+-------------+-------------------+----------+--------+
| onap-k8s         | integration | infra-healthcheck | 00:06    | PASS   |
| onap-helm        | integration | infra-healthcheck | 00:01    | PASS   |
| nodeport_ingress |  security   |  security         | 00:01    | FAIL   |
+------------------+-------------+-------------------+----------+--------+
```
