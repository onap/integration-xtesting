#!/usr/bin/env python
#
# Copyright (C) 2026 Deutsche Telekom. All rights reserved.
# This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
#
# http://www.apache.org/licenses/LICENSE-2.0
#

"""Robot Framework listener recording a run as OpenTelemetry spans."""

from opentelemetry import context, trace
from opentelemetry.trace import Status, StatusCode

tracer = trace.get_tracer(__name__)

MAX_KEYWORD_DEPTH = 3


class TracingListener:
    """Open a span per suite, test and keyword down to MAX_KEYWORD_DEPTH.

    Each span is the current context while it is open, so the HTTP calls
    made by the keywords become its children instead of separate traces.
    """

    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self._spans = []
        self._keyword_depth = 0

    def start_suite(self, name, attrs):
        self._start(f"suite.{name}", {
            "robot.suite.name": attrs["longname"],
            "robot.suite.source": attrs["source"] or "",
        })

    def end_suite(self, _name, attrs):
        self._end(attrs)

    def start_test(self, name, attrs):
        self._start(f"test.{name}", {
            "robot.test.name": attrs["longname"],
            "robot.test.tags": attrs["tags"],
        })

    def end_test(self, _name, attrs):
        self._end(attrs)

    def start_keyword(self, name, attrs):
        self._keyword_depth += 1
        if self._keyword_depth <= MAX_KEYWORD_DEPTH:
            self._start(f"keyword.{name}", {
                "robot.keyword.name": name,
                "robot.keyword.type": attrs["type"],
            })

    def end_keyword(self, _name, attrs):
        if self._keyword_depth <= MAX_KEYWORD_DEPTH:
            self._end(attrs)
        self._keyword_depth -= 1

    def _start(self, span_name, attributes):
        span = tracer.start_span(span_name, attributes=attributes)
        token = context.attach(trace.set_span_in_context(span))
        self._spans.append((span, token))

    def _end(self, attrs):
        span, token = self._spans.pop()
        span.set_attribute("robot.status", attrs["status"])
        if attrs["status"] == "FAIL":
            span.set_status(Status(StatusCode.ERROR, attrs.get("message")))
        context.detach(token)
        span.end()
