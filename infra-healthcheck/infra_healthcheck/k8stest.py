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
import os
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
        result_folder = "{}/{}".format(self.dir_results, self.case_name)
        file_name = "{}/{}.log".format(result_folder, self.case_name)
        os.makedirs(result_folder, exist_ok=True)

        log_file = open(file_name, "w")
        log_file.write(output)
        log_file.close()

        remarks = []
        details = {}
        lines = output.split('\n')
        success = False
        str_remarks = ""

        for log in lines:
            if log.startswith(">>>"):
                remarks.append(log.replace('>', ''))
            else:
                remarks.append(log)
        if 'PASS' in remarks:
            success = True

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


class OnapSecurityNodePortsIngress(K8sTesting):
    """Check that there is no NodePort without corresponding Ingress port."""
    def __init__(self, **kwargs):
        super(OnapSecurityNodePortsIngress, self).__init__(**kwargs)
        self.cmd = ['python3', '/check_for_ingress_and_nodeports.py',
                    '--conf', '/root/.kube/config']
        self.error_string = "NodePort without corresponding Ingress found"

class OnapSecurityNodePortsCerts(K8sTesting):
    """Check the cerfificates fot he nodeports."""
    def __init__(self, **kwargs):
        super(OnapSecurityNodePortsCerts, self).__init__(**kwargs)
        os.chdir('/usr/lib/python3.8/site-packages/check_certificates')
        self.cmd = ['python3', 'check_certificates_validity.py',
                    '--mode','nodeport','--namespace','onap','--dir',
                    '/var/lib/xtesting/results/nodeport_check_certs']
        self.criteria_string = ">>> Test Check certificates PASS"