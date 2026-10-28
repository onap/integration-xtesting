# Copyright (C) 2026 Deutsche Telekom AG
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Documentation    DMI aggregate health and Swagger UI availability.
Resource    healthcheck.resource
Suite Setup    Create Session    healthcheck    http://${DMI_HOST}:${DMI_PORT}
Suite Teardown    Delete All Sessions

*** Test Cases ***
Test DMI Enhanced Healthcheck
    Check Aggregate Health

Test DMI Swagger UI
    Check Swagger UI
