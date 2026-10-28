# Smoke use cases robot py3

## Goal

The tests are:

- cps-healthcheck
- cps-temporal-healthcheck
- cps-dmi-plugin-healthcheck

The CPS and DMI healthchecks are maintained in [tests](tests) and packaged
in the image. They do not depend on the removed upstream CSIT suites.
Each checks that:

- `/actuator/health` returns HTTP 200, valid JSON with `status: UP`, and
  no `DOWN` component.
- `/swagger-ui/index.html` returns HTTP 200.

Requests are unauthenticated and have a 10-second timeout. The existing
`CPS_CORE_HOST` / `CPS_CORE_PORT` and `DMI_HOST` / `DMI_PORT` variables
select the target services. These read-only checks retain the xtesting case
names and Robot report locations. They do not register devices or run the
upstream k6 integration scenarios.

CPS Temporal continues to use its upstream CSIT suite. Image builds check
that all three healthcheck suites and the shared Robot resource exist.

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
