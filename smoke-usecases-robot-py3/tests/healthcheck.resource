# Copyright (C) 2026 Deutsche Telekom AG
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Library    Collections
Library    RequestsLibrary

*** Keywords ***
Check Aggregate Health
    ${response}=    GET On Session    healthcheck    /actuator/health
    ...    expected_status=200    timeout=10
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${body}    status    UP
    Should Not Contain    ${response.text}    DOWN

Check Swagger UI
    GET On Session    healthcheck    /swagger-ui/index.html
    ...    expected_status=200    timeout=10
