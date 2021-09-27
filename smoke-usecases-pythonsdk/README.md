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
  GR-API (A la Carte SO BPMN). The components used are SDC, SO, AAI, SDNC.
- basic_cnf: onboarding/distribution/deployment of a single nginx pod in ONAP using
  GR-API (A la Carte SO BPMN) and K8s module. The components used are SDC, SO,
  AAI, SDNC, MultiCloud.
- basic_network: onboarding/distribution/deployment of a Neutron network
- basic_vm_macro: same as basic_vm but using the macro BPMN
- basic_vm_macro_stability: same as basic_vm_macro but using a pre-enriched CBA
- pnf_macro: instantiation of a pnf using Macro mode including a pnf simulator
- basic_onboard: onboard a model in SDC
- basic_CDS: check the CBA enrichment feature
- basic_clamp: design and deploy a loop using clamp (integrated in SDC), at the end
  designed loop shall be deployed in Policy and DCAE (TCA pod created)

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

- OS_TEST_CLOUD: it specifies the Openstack cloud you
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
ONAP_PYTHON_SDK_SETTINGS=onaptests.configuration.basic_vm_settings
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

You can specify the log level, the log file and the path for the reporting page.

You may then indicate several volumes when launching the xtesting docker.
Please note it can be run from any place assuming that the configuration and the
connectivity are properly set. You then need to have access to ONAP endpoints, you
can either copy a /etc/hosts in the docker or add the hosts in the docker command.

The different needed volumes are:

- The local result directory path: to store the results in your local
  environement. It shall corresponds to the internal result docker path
  /var/lib/xtesting/results
- The openstack cloud.yaml for use cases interacting with Openstack
  infrastructures (basic_vm, basic_network)
- The customization of your service. You can overwrite the model datas by the
  values matching your environement. In this case you need to replace the default
  service configuration file
- The kubernetes .kube/config configuration for use cases interacting with kubernetes
  (basic_cnf)
- The target kubernetes .kube/config configuration for basic_cnf, it shall be in the
  templates/artifacts directory of onaptests

An example of clouds.yaml

```
clouds:
    onap-master-daily-vnfs-ci:
        auth:
            auth_url: https://vim.pod4.opnfv.fr:5000
            password: yGiJDEh82K9x0T69iIJJRPeUqVRPFnIR
            project_id: 978ec1ae58ac492a936e0bcec22dfee9
            project_name: onap-master-daily-vnfs
            user_domain_name: Default
            username: onap-master-daily-vnfs-ci
        compute_api_version: '2.15'
        identity_api_version: '3'
        interface: public
        project_domain_name: Default
        region_name: RegionOne
```

A example of basic_vm customization is provided hereafter. You can customize
this file according to your cloud environment (key, flavor name,..).
The data will be preloaded to overwrite the default model values.

```
---
basic_vm:
    vnfs:
        - vnf_name: basic_vm
          heat_files_to_upload: onaptests/templates/heat-files/ubuntu20/ubuntu20agent.zip
          vnf_parameters: [
              {"name": "ubuntu20_image_name",
               "value": "ubuntu-agent"
              },
              {"name": "ubuntu20_key_name",
               "value": "cleouverte"
              },
              {"name": "ubuntu20_pub_key",
               "value": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAA\
BAQDY15cdBmIs2XOpe4EiFCsaY6bmUmK/GysMoLl4UG51JCfJwvwoWCoA+6mDIbymZxhxq9IGx\
ilp/yTA6WQ9s/5pBag1cUMJmFuda9PjOkXl04jgqh5tR6I+GZ97AvCg93KAECis5ubSqw1xOCj4\
utfEUtPoF1OuzqM/lE5mY4N6VKXn+fT7pCD6cifBEs6JHhVNvs5OLLp/tO8Pa3kKYQOdyS0xc3r\
h+t2lrzvKUSWGZbX+dLiFiEpjsUL3tDqzkEMNUn4pdv69OJuzWHCxRWPfdrY9Wg0j3mJesP29EBh\
t+w+EC9/kBKq+1VKdmsXUXAcjEvjovVL8l1BrX3BY0R8D imported-openssh-key"
              },
              {"name": "ubuntu20_flavor_name",
               "value": "m1.smaller"
              },
              {"name": "VM_name",
               "value": "ubuntu20agent-VM-01"
              },
              {"name": "vnf_id",
               "value": "ubuntu20agent-VNF-instance"
              },
              {"name": "vf_module_id",
               "value": "ubuntu20agent-vfmodule-instance"
              },
              {"name": "vnf_name",
               "value": "ubuntu20agent-VNF"
              },
              {"name": "admin_plane_net_name",
               "value": "admin"
              }
          ]
```

### Commands

If you specify all the hosts

```
docker run
--env-file <your local env>
-v <cloud.yaml file corresponding to your VNF tenant>:/root/.config/openstack/clouds.yaml
-v <kube config file corresponding to your k8s cluster>:/root/.kube/config
-v <service definition yaml matching your environment>:/usr/lib/python3.8/site-packages/onaptests/templates/vnf-services/basic_vm-service.yaml
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
nexus3.onap.org:10003/onap/xtesting-smoke-usecases-pythonsdk:master /bin/sh -c "run_tests -t basic_vm"
```

```
docker run
--env-file <your local env>
-v <cloud.yaml file corresponding to your VNF tenant>:/root/.config/openstack/clouds.yaml
-v <kube config file corresponding to your onap k8s cluster>:/root/.kube/config
-v <kube config file corresponding to your target k8s cluster>:/src/onaptests/src/onaptests/templates/artifacts/config
-v <service definition yaml matching your environment>:/usr/lib/python3.8/site-packages/onaptests/templates/vnf-services/basic_vm-service.yaml
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
nexus3.onap.org:10003/onap/xtesting-smoke-usecases-pythonsdk:master /bin/sh -c "run_tests -t basic_cnf"
```

Unkike the other xtesting dockers, 1 docker = 1 use case, the target -t all is
not usable.

Note you can also run the docker interactively

```
docker run -it
-env-file <your local env>
-v <cloud.yaml file corresponding to your VNF tenant>:/root/.config/openstack/clouds.yaml
-v <kube config file corresponding to your k8s cluster>:/root/.kube/config
-v <result directory>:/var/lib/xtesting/results
nexus3.onap.org:10003/onap/xtesting-smoke-usecases-pythonsdk:master sh
```

Inside the docker you can edit the /etc/hosts and indicate the different hosts).
You can also edit the configuration file
/usr/lib/python3.8/site-packages/onaptests/templates/vnf-services/basic_vm-service.yaml
You can also edit the tester and test settings in
/usr/lib/python3.8/site-packages/onaptests.
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
