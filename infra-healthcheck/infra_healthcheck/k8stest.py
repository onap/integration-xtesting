#!/usr/bin/env python
#
# Copyright (c) 2018 All rights reserved
# This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
#
# http://www.apache.org/licenses/LICENSE-2.0
#

"""
Define the parent for Kubernetes testing.
"""

from __future__ import division

import logging
import subprocess
import time

from xtesting.core import testcase


class K8sTesting(testcase.TestCase):
    """Kubernetes test runner"""

    __logger = logging.getLogger(__name__)

    def __init__(self, **kwargs):
        super(K8sTesting, self).__init__(**kwargs)
        self.cmd = []
        self.result = 0
        self.details = {}
        self.start_time = 0
        self.stop_time = 0
        self.criteria_string = ""

    def run_kubetest(self):  # pylint: disable=too-many-branches
        """Run the test suites"""
        cmd_line = self.cmd
        self.__logger.info("Starting k8s test: '%s'.", cmd_line)

        process = subprocess.Popen(cmd_line, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT)
        output = process.stdout.read().decode("utf-8")
        if ('Error loading client' in output or
                'Unexpected error' in output):
            raise Exception(output)

        # create a log file
        file_name = "/var/lib/xtesting/results/" + self.case_name + ".log"
        log_file = open(file_name, "w")
        log_file.write(output)
        log_file.close()

        remarks = []
        details = {}
        lines = output.split('\n')
        success = False

        for log in lines:
            if log.startswith(">>>"):
                remarks.append(log.replace('>', ''))
        for remark in remarks:
            if ':' in remark:
                # 2 possible Results
                # * numeric nb pods, failed, duration
                # * list of pods, charts,...
                if '[' in remark:
                    # it is a list
                    str1 = remark.split(":", 1)[1].strip().replace(
                        ']', '').replace('[', '')
                    details[remark.split(":", 1)[0].strip()] = str1.split(",")
                else:
                    details[remark.split(":", 1)[0].strip()] = int(
                        remark.split(":", 1)[1].strip())

        # if 1 pod/helm chart if Failed, the testcase is failed
        if int(details[self.criteria_string]) < 1:
            success = True

        self.details = details
        self.__logger.info("details: %s", details)

        if success:
            self.result = 100
        else:
            self.result = 0

    def run(self, **kwargs):

        self.start_time = time.time()
        try:
            self.run_kubetest()
            res = self.EX_OK
        except Exception:  # pylint: disable=broad-except
            self.__logger.exception("Error with running kubetest:")
            res = self.EX_RUN_ERROR

        self.stop_time = time.time()
        return res


class OnapK8sTest(K8sTesting):
    """Kubernetes smoke test suite"""
    def __init__(self, **kwargs):
        if "case_name" not in kwargs:
            kwargs.get("case_name", 'onap-k8s')
        super(OnapK8sTest, self).__init__(**kwargs)
        self.cmd = ['/check_onap_k8s.sh']
        self.criteria_string = "Nb Failed Pods"


class OnapHelmTest(K8sTesting):
    """Kubernetes conformance test suite"""
    def __init__(self, **kwargs):
        if "case_name" not in kwargs:
            kwargs.get("case_name", 'onap-helm')
        super(OnapHelmTest, self).__init__(**kwargs)
        self.cmd = ['/check_onap_helm.sh']
        self.criteria_string = "Nb Failed Helm Charts"
