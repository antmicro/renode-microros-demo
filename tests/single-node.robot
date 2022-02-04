*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Print DeviceID
    Execute Script              ${CURDIR}/first_instance.resc
    Create Terminal Tester      sysbus.uart2
    Start Emulation
    Wait For Next Line On Uart  20
    Teardown
Should Wait For Handshake
    Execute Script              ${CURDIR}/first_instance.resc
    Create Terminal Tester      sysbus.uart1
    Create Terminal Tester      sysbus.uart2
    Start Emulation
    Wait For Prompt On Uart     ~  1   20
Should Start Sending Messages
    ${agent}=                   Start Process		        ${CURDIR}/start_agent.sh    ${CURDIR}	shell=True	stdout=${CURDIR}/out.txt    stderr=${CURDIR}/err.txt 
    Execute Script              ${CURDIR}/first_instance.resc
    Create Terminal Tester      sysbus.uart1
    Create Terminal Tester      sysbus.uart2
    Start Emulation
    Wait For Line On Uart       Sending .{1,}  15  2  treatAsRegex=true
    Terminate Process           ${agent}
