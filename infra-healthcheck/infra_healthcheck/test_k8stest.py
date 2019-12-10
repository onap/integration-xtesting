#!/usr/bin/env python
#
# Copyright (c) 2018 All rights reserved
# This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
#
# http://www.apache.org/licenses/LICENSE-2.0
#

"""Define the classes required to fully cover k8s."""

import logging
import os
import unittest


from infra_healthcheck import k8stest


class K8sTests(unittest.TestCase):

    # pylint: disable=missing-docstring

    def setUp(self):
        os.environ["DEPLOY_SCENARIO"] = "k8-test"
        os.environ["KUBE_MASTER_IP"] = "127.0.0.1"
        os.environ["KUBE_MASTER_URL"] = "https://127.0.0.1:6443"
        os.environ["KUBERNETES_PROVIDER"] = "local"

        self.k8stesting = k8stest.K8sTesting()

    def test_run_kubetest_cmd_none(self):
        self.k8stesting.cmd = None
        with self.assertRaises(TypeError):
            self.k8stesting.run_kubetest()


if __name__ == "__main__":
    logging.disable(logging.CRITICAL)
    unittest.main(verbosity=2)
