#!/bin/bash

source /opt/ros/$ROS_DISTRO/setup.bash
mkdir microros_ws
cd microros_ws
git clone -b $ROS_DISTRO https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup
rosdep update
rosdep install --from-path src --ignore-src -y
colcon build
source install/local_setup.bash
ros2 run micro_ros_setup create_firmware_ws.sh zephyr stm32f4_disco
cd firmware/zephyr_apps/apps
cp -r ../../../../src/microros-sensor-publisher-subscriber ./
cd ../../../
ros2 run micro_ros_setup configure_firmware.sh microros-sensor-publisher-subscriber --transport serial
cd firmware/zephyr_apps/microros_extensions/
sed 's/.*{.fd = 0};.*/    static zephyr_transport_params_t default_params = {.fd = 1};/' microros_transports.h -i
cd ../../../
ros2 run micro_ros_setup build_firmware.sh
mkdir agent_ws
cd agent_ws
ros2 run micro_ros_setup create_agent_ws.sh
ros2 run micro_ros_setup build_agent.sh
source install/local_setup.bash
cd ..
mkdir ros2_ws
cd ros2_ws
mkdir src
cp -r ../../src/ros2-sensor-subscriber src/
colcon build
cd ..

