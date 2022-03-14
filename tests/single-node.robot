*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Print DeviceID
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Create Terminal Tester      sysbus.usart2
    Start Emulation
    Wait For Next Line On Uart  20
    Teardown
Should Wait For Handshake
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Create Terminal Tester      sysbus.usart1
    Create Terminal Tester      sysbus.usart2
    Start Emulation
    Wait For Prompt On Uart     ~   0   20
Should Start Sending Messages
    ${agent}=                   Start Process		        ${CURDIR}/../renode/start_agent.sh    ${CURDIR}/../renode	shell=True	stdout=${CURDIR}/../renode/out.txt    stderr=${CURDIR}/../renode/err.txt 
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Create Terminal Tester      sysbus.usart1
    Create Terminal Tester      sysbus.usart2
    Start Emulation
    Wait For Line On Uart       Sending .{1,}  15  1  treatAsRegex=true
    Terminate Process           ${agent}
