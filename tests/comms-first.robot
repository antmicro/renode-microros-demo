*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Receive A Message
    ${agent}=                   Start Process		${CURDIR}/start_agent.sh    ${CURDIR} 	shell=True  stdout=${CURDIR}/frist_out.txt    stderr=${CURDIR}/first_err.txt
    Execute Script              ${CURDIR}/first_instance.resc
    Create Terminal Tester      sysbus.uart1
    Create Terminal Tester      sysbus.uart2
    Start Emulation
    Wait For Line On Uart       Data frame .{1,}  30  2  treatAsRegex=true
    Sleep                       10
    Terminate Process           ${agent}
