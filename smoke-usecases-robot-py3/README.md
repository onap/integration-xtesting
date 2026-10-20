# Smoke use cases robot py3

## Goal

The tests are:

- cps-healthcheck
- cps-temporal-healthcheck
- cps-ncmp-dmi-plugin-healthcheck

## Usage

See [smoke-usecases-robot README](../smoke-usecases-robot/README.md)
for details.

This docker is behaving the same except that it is python3 with
more recent version of robot libraries.

## Tracing

The testcases run with the `robotframework_otel` driver. When started with
`opentelemetry-instrument`, each testcase is exported as one trace with a
`scenario.<case_name>` root span and spans for the suites, tests and the top
three keyword levels. The HTTP calls of the keywords are children of these
spans.
