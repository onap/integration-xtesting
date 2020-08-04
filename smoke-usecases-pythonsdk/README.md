# Smoke use cases

## Goal

The goal of this docker is to run End to End use cases on ONAP in order to
check the solution. The testcases defined in this docker MUST be PASS to
validate the release.
The test cases can be run using Robot framework or onap-test (ONAP python SDK).
Bash, python and unit test drivers also exist. Additionnal drivers can be added
but the Dockerfile must be adapted accordingly.

The tests are:

- basic_vm: it onboard/distribute/deploy a single Ubuntu VM in ONAP using
  VNF-API. The components used are SDC, SO, AA&I, SDNC.
- freeradius_nbi: based on basic_vm, the instantiation part is done through the
  ONAP external API (NBI) module.
- clearwater_ims: it consists in a full deployment of an clearwater vIMS in ONAP.

## Usage

Note this docker will be deprecated in Guilin. The existing 3 test cases and
additional ones will be performed through test cases [2] consuming the Python
ONAP SDK [1]

### Configuration

Mandatory:

Assuming that these use cases were based on onap-tests, the service descriptions
must be overwritten with the right cloud informations as well as the onap-tests
configuration. That is why 2 volumes are needed:

- <custom onap-tests config>: The last section of the default configuration must
  be adapted to your environement [3]
- <service description dir>: the customized service descriptions including the
  parameters to be overwritten (SDNC preload) [4]

Optional:

- The local result directory path: to store the results in your local
  environement. It shall corresponds to the internal result docker path
  /var/lib/xtesting/results
- The cloud.yaml if you enable the Openstack verification option (Openstack
  client call to check that the stack is created in Openstack)

### Command

```
docker run
-v <your local env>:/var/lib/xtesting/conf/env_file
-v <custom onap-tests config>:/usr/lib/python3.8/site-packages/onap_tests/onap-conf/onap-testing.yaml
-v <service description dir>:/usr/lib/python3.8/site-packages/onap_tests/templates/vnf-services
-v <cloud.yaml file corresponding to your VNF tenant>/root/.config/openstack.yaml
-v <result directory>:/var/lib/xtesting/results
nexus3.onap.org:10001/onap/xtesting-infra-healthcheck:latest
```

### Output

[1]: https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk "Python ONAP SDK repository"

[2]: https://git.onap.org/testsuite/pythonsdk-tests/tree/ "Scenario consuming Python SDK"

[3]: https://gitlab.com/Orange-OpenSource/lfn/onap/onap-tests/-/blob/master/onap_tests/onap-conf/onap-testing.yaml "onap-test configuration"

[4]: https://gitlab.com/Orange-OpenSource/lfn/onap/xtesting-onap/-/tree/master/roles/xtesting-onap-vnf "File and templates of service descriptions"
