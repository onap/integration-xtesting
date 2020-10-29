# Smoke use cases

## Goal

The goal of this docker is to run End to End use cases on ONAP in order to
check the solution. The testcases defined in this docker MUST be PASS to
validate the release.
The test cases can be run using Robot framework or onap-test (ONAP python SDK).
Bash, python and unit test drivers also exist. Additionnal drivers can be added
but the Dockerfile must be adapted accordingly.

The tests are:

- basic_vm: onboarding/distribution/deployment of a single Ubuntu VM in ONAP using
  GR-API (A la Carte SO BPMN). The components used are SDC, SO, AA&I, SDNC.
- basic_cnf: onboarding/distribution/deployment of a single nginx pod in ONAP using
  GR-API (A la Carte SO BPMN) and K8s module. The components used are SDC, SO,
  AA&I, SDNC, MultiCloud.
- basic_network: onboarding/distribution/deployment of a Neutron network

## Usage

Tests are  performed through test cases [2] consuming the Python
ONAP SDK [1].

### Configuration

Mandatory:

Assuming that these use cases were based on onap-tests, the service descriptions
must be overwritten with the right cloud informations as well as the onap-tests
configuration.

pythonsdk-tests configuration is given by a file whose path is specified in env
variables. It is therefore needed to setup env files and precise the
test configuration.

There are optional and mandatory env variables

Mandatory:
-  OS_TEST_CLOUD: it specifies the Openstack cloud you
  are using (declared in the clouds.yaml)
- ONAP_PYTHON_SDK_SETTINGS: the configuration to be considered for the tests.
  See pythonsdk-tests README for details

Optional:
- INSTALLER_TYPE: the name of the installer (used for results)
- TEST_DB_URL: the url of the DB you want to push the results
- NODE_NAME: the name of the lab or CI chain (used for results)
- BUILD_TAG: an id used for CI to group tests in a CI run
- DEBUG: by default xtesting logs are not enables

An example of env file is given herefater:

```
INSTALLER_TYPE=oom
TEST_DB_URL=http://testresults.opnfv.org/onap/api/v1/results
NODE_NAME=onap_daily_pod4_master-ONAP-oom
BUILD_TAG=gitlab_ci-functest-kubespray-baremetal-daily-master-209039216-onap
DEBUG=True
OS_TEST_CLOUD=onap-master-daily-vnfs-ci
ONAP_PYTHON_SDK_SETTINGS=onaptests.configuration.ubuntu16_nomulticloud_settings
```

The generic configuration file settings.py can be also specified to overwritte
default values.

```
"""Specific settings module."""  # pylint: disable=bad-whitespace

######################
#                    #
# ONAP INPUTS DATAS  #
#                    #
######################


# Variables to set logger information
# Possible values for logging levels in onapsdk: INFO, DEBUG , WARNING, ERROR
LOG_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "default": {
            "class": "logging.Formatter",
            "format": "%(asctime)s %(levelname)s %(lineno)d:%(filename)s(%(process)d) - %(message)s"
        }
    },
    "handlers": {
        "console": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "default"
        },
        "file": {
            "level": "DEBUG",
            "class": "logging.FileHandler",
            "formatter": "default",
            "filename": "/var/lib/xtesting/results/pythonsdk.debug.log",
            "mode": "w"
        }
    },
    "root": {
        "level": "DEBUG",
        "handlers": ["console", "file"]
    }
}

# SOCK_HTTP = "socks5h://127.0.0.1:8080"
REPORTING_FILE_PATH = "/var/lib/xtesting/results/reporting.html"
K8S_REGION_TYPE = "k8s"
```

You can specify the log level, the log file, and the path for the reporting page.

You may then indicate several volumes when launching the xtesting docker.
Please note it can be run from anyplace assuming that the configuration and the
connectivity are properly set. You then need to hav access to ONAP endpoints, you
can either copy a /etc/hosts in the docker or add the hosts in the docker command.

The different needed volumes are:

- The local result directory path: to store the results in your local
  environement. It shall corresponds to the internal result docker path
  /var/lib/xtesting/results
- The kubernetes .kube/config configuration for use cases interacting with kubernetes
  (basic_cnf)
  - The openstack cloud.yaml for use cases interacting with Openstack
    infrastructures (basic_vm, basic_network)

### Command

If you specify all the hosts
```
docker run
-v <your local env>:/var/lib/xtesting/conf/env_file
-v <cloud.yaml file corresponding to your VNF tenant>/root/.config/openstack.yaml
-v <kube config file corresponding to your k8s cluster>/root/.kube/config
-v <result directory>:/var/lib/xtesting/results
--add-host="portal.api.simpledemo.onap.org:<your ONAP IP>"
--add-host="vid.api.simpledemo.onap.org:<your ONAP IP>"
--add-host="sdc.api.fe.simpledemo.onap.org:<your ONAP IP>"
--add-host="sdc.api.be.simpledemo.onap.org:<your ONAP IP>"
--add-host="aai.api.sparky.simpledemo.onap.org:<your ONAP IP>"
--add-host="so.api.simpledemo.onap.org:<your ONAP IP>"
--add-host="sdnc.api.simpledemo.onap.org:<your ONAP IP>"
--add-host="sdc.workflow.plugin.simpledemo.onap.org:<your ONAP IP>"
--add-host="sdc.dcae.plugin.simpledemo.onap.org:<your ONAP IP>"
--add-host="msb.api.simpledemo.onap.org:<your ONAP IP>"
nexus3.onap.org:10003/onap/xtesting-smoke-usecases-pythonsdk:latest /bin/sh -c "run_tests -t basic_vm"
```

Unkike the other xtesting docker, 1 docker = 1 use case, the target -t all is
not usable.

Note you can run also the docker interactivly

```
docker run -it
-v <your local env>:/var/lib/xtesting/conf/env_file
-v <cloud.yaml file corresponding to your VNF tenant>/root/.config/openstack.yaml
-v <kube config file corresponding to your k8s cluster>/root/.kube/config
-v <result directory>:/var/lib/xtesting/results
nexus3.onap.org:10003/onap/xtesting-smoke-usecases-pythonsdk:latest sh
```
Inside the docker you can edit the /etc/hosts and indicate the different hosts).
Then you can run the test with the following command:
```
run_tests -t basic_vm
```
you can modify the env variable to run any of the use cases.

### Output

```
+-------------------+---------------------+------------------+----------------+
|     TEST CASE     |       PROJECT       |     DURATION     |     RESULT     |
+-------------------+---------------------+------------------+----------------+
|      basic_vm     |     integration     |      09:52       |      PASS      |
+-------------------+---------------------+------------------+----------------+
```

### references

[1]: https://gitlab.com/Orange-OpenSource/lfn/onap/python-onapsdk "Python ONAP SDK repository"

[2]: https://git.onap.org/testsuite/pythonsdk-tests/tree/ "Scenario consuming Python SDK"

[3]: https://gitlab.com/Orange-OpenSource/lfn/onap/onap-tests/-/blob/master/onap_tests/onap-conf/onap-testing.yaml "onap-test configuration"

[4]: https://gitlab.com/Orange-OpenSource/lfn/onap/xtesting-onap/-/tree/master/roles/xtesting-onap-vnf "File and templates of service descriptions"
