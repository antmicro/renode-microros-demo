*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Receive Messages On ROS2
    ${agent}=                       Start Process		        ${CURDIR}/../renode/start_agent.sh     ${CURDIR}/../renode   	shell=True      stdout=${CURDIR}/../renode/out.txt    stderr=${CURDIR}/../renode/err.txt 
    Execute Script                  ${CURDIR}/../renode/first_instance.resc
    Create Terminal Tester          sysbus.usart1
    Create Terminal Tester          sysbus.usart2
    Start Emulation 
    Wait For Line On Uart           Sending .{1,}  15  1  treatAsRegex=true
    ${receiver_handle}=             Start Process               stdbuf -oL ros2 run subscriber subscriber_node    stdout=${CURDIR}/../renode/ros_out.txt   shell=True
    Wait Until Keyword Succeeds     60 sec      1 sec           File Should Contain     Got from MicroROS .{1,}   ${CURDIR}/../renode/ros_out.txt
    Log To Console                  Processed Match
    Terminate Process               ${agent}

*** Keywords ***
File Should Contain 
    [Arguments]                     ${regex}                    ${filename}
    ${result}=                      Run Process                 cat ${filename}     shell=True
    Should Match Regexp             ${result.stdout}            ${regex}