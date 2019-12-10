# Smoke use cases

## Goal

The goal of this docker is to run End to End use cases on ONAP in order to
check the solution. The testcases defined in this docker MUST be PASS to
validate the release.
The test cases can be run using Robot framework or onap-test (ONAP python SDK).
Bash, python and unit test drivers also exist. Additionnal drivers can be added
but the Dockerfile must be adapted accordingly.

The tests are:

* basic_vm: it onboard/distribute/deploy a single Ubuntu VM in ONAP using
  VNF-API. The components used are SDC, SO, AA&I, SDNC.
* freeradius_nbi: based on basic_vm, the instantiation part is done through the
  ONAP external API (NBI) module.
* clearwater_ims: it consists in a full deployment of an clearwater vIMS in ONAP.

## Usage

### Configuration

### Command

### Output
