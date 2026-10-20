#!/usr/bin/env python
#
# Copyright (C) 2026 Deutsche Telekom. All rights reserved.
# This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
#
# http://www.apache.org/licenses/LICENSE-2.0
#

"""RobotFramework driver exporting each testcase as one trace."""

import functools
from unittest import mock

from opentelemetry import trace
from xtesting.core import robotframework

from onap_robot_tracing.listener import TracingListener

tracer = trace.get_tracer(__name__)


class TracedRobotFramework(robotframework.RobotFramework):
    """Run the suites under a scenario span with the tracing listener."""

    def run(self, **kwargs):
        # The xtesting driver of the base image calls robot.run() with a fixed
        # option list, so a listener cannot be passed in the testcase args.
        run_with_listener = functools.partial(
            robotframework.robot.run, listener=TracingListener())
        with tracer.start_as_current_span(
                f"scenario.{self.case_name}",
                attributes={"scenario.case_name": self.case_name}) as span, \
                mock.patch.object(robotframework.robot, "run", run_with_listener):
            status = super().run(**kwargs)
            span.set_attribute("scenario.result", self.result)
            return status
