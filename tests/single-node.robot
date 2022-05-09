*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Print DeviceID
    Execute Script              ${CURDIR}/../renode/zynq.resc
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Create Terminal Tester      sysbus.usart2        machine=stm32-1
    Start Emulation
    Wait For Next Line On Uart  30
    Teardown
Should Wait For Handshake
    Execute Script              ${CURDIR}/../renode/zynq.resc
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Create Terminal Tester      sysbus.usart1        machine=stm32-1
    Start Emulation
    Wait For Prompt On Uart     ~   0   20 
Should Start Sending Messages
    Execute Script              ${CURDIR}/../renode/zynq.resc
    Create Terminal Tester      sysbus.uart1
    Start Emulation
    Sleep                       130
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Start Emulation
    Create Terminal Tester      sysbus.usart2        machine=stm32-1
    Wait For Line On Uart       Sending .{1,}       15      testerId=1      treatAsRegex=true

