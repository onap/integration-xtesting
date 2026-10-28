# Copyright (C) 2026 Deutsche Telekom AG
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Documentation    CPS aggregate health and Swagger UI availability.
Resource    healthcheck.resource
Suite Setup    Create Session    healthcheck    http://${CPS_CORE_HOST}:${CPS_CORE_PORT}
Suite Teardown    Delete All Sessions

*** Test Cases ***
Test CPS Enhanced Healthcheck
    Check Aggregate Health

Test CPS Swagger UI
    Check Swagger UI
