# Healthcheck

## Goal

This healthcheck docker includes the test suites checking ONAP components.

It includes 4 tests:

* core: robot basic healthcheck of the components AAI, dmaap, portal, SDC, SDNC,
  SO
* small: robot basic healthcheck of the components AAI, dmaap, portal, SDC, SDNC,
  SO, AAF, APPC, CLI, LOG, MSB, Mulicloud, VID
* medium: robot basic healthcheck of the components AAI, dmaap, portal, SDC, SDNC,
  SO, AAF, APPC, CLI, LOG, MSB, Mulicloud, VID, CDS, CLAMP, Dcaegen2, OOF,
  Policy, UUI
* full: all the components
* healthdist: test the onboarding and the distribution of the vFW

## Usage

### Configuration

Mandatory:

* The Robot configuration file: this file is setup at ONAP installation in the
  configmap onap-robot-robot-eteshare-configmap. It includes lots of variables,
  end points, urls, passwords, logins, needed by the robot scripts.
  By default most of these data are set at ONAP installation.
  Please note that some use cases may require additional data. A overide.yaml
  file shall be created to provide these extra data.
  As an example the keystone url is set in this config map by default to
  <http://1.2.3.4:5000>. This can be modified at installation and adapted
  according to your cloud configuration.

Optional:

* The local result directory path: to store the results in your local
  environement. It shall corresponds to the internal result docker path
  /var/lib/xtesting/results

### Command

For the robot use cases, it is recommended to create a kubernetes jobs and run
the image as a jobs within onap namespace.
An example of job is provided in the job subdirectory. You need to setup the
following variables:

* Mandatory:
  * run_type: the name of the use case: core, small, medium, full, healthdist
  * onap_namespace: onap name space (usually set to onap)
* Optional:
  * deployment_name: parameter for the results pushed into the database (e.g.
    daily-master)
  * deploy_scenario: parameter for the results pushed into the database (e.g.
    rke_istio_baremetal)
  * node_name: parameter for the results pushed into the database. This
    parameter must match the pod declaration in the database otherwise the
    results will not be accepted
  * test_result_url: the url of the test database
  * build_tag: parameter for the results pushed into the database. It is used to
    identify the CI run. It can be used indirectly to retrieve the version
  * res_local_path: the path where you want to save the result logs on your
    local machine

By default (in scripts/cmd.sh), the -r option is enabled in the job template.
It means that xtesting will try to push the results to the DB.
If the parameters are not set, an error will be displayed (DB not reachable)

### Output

```
+-------------------+------------------+------------------+----------------+
|     TEST CASE     |     PROJECT      |     DURATION     |     RESULT     |
+-------------------+------------------+------------------+----------------+
|        core       |     functest     |      00:09       |      PASS      |
+-------------------+------------------+------------------+----------------+
```
