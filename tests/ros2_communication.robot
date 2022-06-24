*** Settings ***
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown
Resource        ${RENODEKEYWORDS}

*** Test Cases ***
Should Receive A Message
    Execute Script              ${CURDIR}/../renode/zynq_login.resc
    Start Emulation
    Create Terminal Tester      sysbus.uart1
    Create Terminal Tester      sysbus.uart0
    Wait For Prompt On Uart     login:                      timeout=150         testerId=0
    Write Line To Uart          root                                            testerId=0
    Execute Script              ${CURDIR}/../renode/first_instance.resc
    Start Emulation
    Wait For Prompt On Uart     root@zedboard-zynq7:~#      timeout=150         testerId=0
    Write Line To Uart          . /usr/bin/ros_setup.sh                         testerId=0
    Wait For Prompt On Uart     root@zedboard-zynq7:~#      timeout=150         testerId=0
    Write Line To Uart          . /usr/share/subscriber/local_setup.sh          testerId=0
    Wait For Prompt On Uart     root@zedboard-zynq7:~#      timeout=150         testerId=0
    Write Line To Uart          export ROS_DOMAIN_ID=0                         testerId=0
    Wait For Prompt On Uart     root@zedboard-zynq7:~#      timeout=150         testerId=0
    Write Line To Uart          export RMW_IMPLEMENTATION=rmw_fastrtps_cpp      testerId=0
    Wait For Prompt On Uart     root@zedboard-zynq7:~#      timeout=150         testerId=0
    Write Line To Uart          ros2 run subscriber subscriber_node             testerId=0
    Wait For Line On Uart       Got from                    150                  testerId=0    treatAsRegex=true
