*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Receive A Message
    Execute Script              ${CURDIR}/../renode/zynq.resc
    Execute Command       emulation SetGlobalSerialExecution true
    Create Terminal Tester      sysbus.uart1
    Create Terminal Tester      sysbus.uart0
    Start Emulation
    Sleep                       130
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Start Emulation
    Execute Script              ${CURDIR}/../renode/second_instance.resc
    Start Emulation
    Create Terminal Tester      sysbus.usart2        machine=stm32-1
    Create Terminal Tester      sysbus.usart2        machine=stm32-2
    Wait For Line On Uart       Data frame from id .{1,}       15      testerId=2      treatAsRegex=true
    Wait For Line On Uart       Data frame from id .{1,}       15      testerId=3      treatAsRegex=true
